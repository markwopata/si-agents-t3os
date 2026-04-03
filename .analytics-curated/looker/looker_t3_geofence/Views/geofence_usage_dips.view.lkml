view: geofence_usage_dips {


  derived_table: {
    sql:
WITH base AS (
    SELECT
        GEOFENCE_ID,
        GEOFENCE_NAME,
        COMPANY_ID,
        ASSET_ID,
        USAGE_DATE,
        HOURS_IN_GEOFENCE
    FROM business_intelligence.triage.stg_t3__geofence_asset_usage
    WHERE COMPANY_ID = 109154
      AND USAGE_DATE >= DATEADD(DAY, -365, CURRENT_DATE)
),

geofence_daily AS (
    SELECT
        GEOFENCE_ID,
        GEOFENCE_NAME,
        COMPANY_ID,
        USAGE_DATE,
        SUM(HOURS_IN_GEOFENCE) AS total_hours
    FROM base
    GROUP BY 1,2,3,4
),

geofence_with_windows AS (
    SELECT
        GEOFENCE_ID,
        GEOFENCE_NAME,
        COMPANY_ID,
        USAGE_DATE,
        total_hours,

        AVG(total_hours) OVER (
            PARTITION BY GEOFENCE_ID
            ORDER BY USAGE_DATE
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS avg_7d,

        AVG(total_hours) OVER (
            PARTITION BY GEOFENCE_ID
            ORDER BY USAGE_DATE
            ROWS BETWEEN 13 PRECEDING AND 7 PRECEDING
        ) AS prev_7d_avg
    FROM geofence_daily
),

latest_snapshot AS (
    SELECT
        GEOFENCE_ID,
        GEOFENCE_NAME,
        COMPANY_ID,
        USAGE_DATE AS snapshot_date,
        avg_7d,
        prev_7d_avg,
        (avg_7d - prev_7d_avg) / NULLIF(prev_7d_avg, 0) AS pct_chg_7d
    FROM geofence_with_windows
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY GEOFENCE_ID
        ORDER BY USAGE_DATE DESC
    ) = 1
),

filtered AS (
    SELECT *
    FROM latest_snapshot
    WHERE avg_7d >= 10
      AND pct_chg_7d < 0
      AND prev_7d_avg IS NOT NULL
),

with_projection AS (
    SELECT
        *,
        (avg_7d * ABS(pct_chg_7d)) AS est_weekly_drop,

        CASE
            WHEN avg_7d * ABS(pct_chg_7d) > 0
            THEN avg_7d / (avg_7d * ABS(pct_chg_7d))
            ELSE NULL
        END AS est_weeks_to_zero,

        DATEADD(
            DAY,
            ROUND(
                CASE
                    WHEN avg_7d * ABS(pct_chg_7d) > 0
                    THEN (avg_7d / (avg_7d * ABS(pct_chg_7d))) * 7
                    ELSE NULL
                END
            ),
            CURRENT_DATE
        ) AS projected_zero_date
    FROM filtered
),

/* Asset concentration (last 30 days) */
last_30_asset_usage AS (
    SELECT
        GEOFENCE_ID,
        ASSET_ID,
        SUM(HOURS_IN_GEOFENCE) AS asset_30d_hours
    FROM base
    WHERE USAGE_DATE >= DATEADD(DAY, -30, CURRENT_DATE)
    GROUP BY 1,2
),

ranked_assets AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY GEOFENCE_ID
            ORDER BY asset_30d_hours DESC
        ) AS rnk
    FROM last_30_asset_usage
),

concentration AS (
    SELECT
        GEOFENCE_ID,
        SUM(CASE WHEN rnk <= 2 THEN asset_30d_hours END)
        / NULLIF(SUM(asset_30d_hours),0) AS top2_concentration
    FROM ranked_assets
    GROUP BY 1
),

classified AS (
    SELECT
        p.*,
        c.top2_concentration,

        CASE
            WHEN pct_chg_7d BETWEEN -0.35 AND -0.10
                 AND est_weeks_to_zero > 4
                 AND COALESCE(top2_concentration,0) < 0.70
            THEN 'EOL'

            WHEN pct_chg_7d <= -0.25
                 AND (
                      est_weeks_to_zero <= 4
                      OR COALESCE(top2_concentration,0) >= 0.70
                 )
            THEN 'MATERIAL_DECLINE'

            ELSE 'MONITOR'
        END AS geofence_status
    FROM with_projection p
    LEFT JOIN concentration c
      ON p.GEOFENCE_ID = c.GEOFENCE_ID
),

/* Top 5 declining geofences by impact (deterministic) */
top5 AS (
    SELECT *
    FROM classified
    ORDER BY (avg_7d * ABS(pct_chg_7d)) DESC, GEOFENCE_ID
    LIMIT 5
),

/* Breadth / handful analysis for the top 5 */
asset_7d_compare AS (
    SELECT
        u.GEOFENCE_ID,
        u.ASSET_ID,

        SUM(CASE
              WHEN u.USAGE_DATE > DATEADD(DAY, -7, g.snapshot_date)
               AND u.USAGE_DATE <= g.snapshot_date
              THEN u.HOURS_IN_GEOFENCE
            END) AS cur_7d_hours,

        SUM(CASE
              WHEN u.USAGE_DATE > DATEADD(DAY, -14, g.snapshot_date)
               AND u.USAGE_DATE <= DATEADD(DAY, -7, g.snapshot_date)
              THEN u.HOURS_IN_GEOFENCE
            END) AS prev_7d_hours
    FROM base u
    JOIN top5 g
      ON u.GEOFENCE_ID = g.GEOFENCE_ID
    GROUP BY 1,2
),

breadth AS (
    SELECT
        GEOFENCE_ID,
        COUNT_IF(prev_7d_hours > 0) AS prev_active_asset_count,
        COUNT_IF(prev_7d_hours > 0 AND (cur_7d_hours - prev_7d_hours) < 0) AS declining_asset_count,
        COUNT_IF(prev_7d_hours > 0 AND (cur_7d_hours - prev_7d_hours) < 0)
            / NULLIF(COUNT_IF(prev_7d_hours > 0), 0)::FLOAT AS pct_assets_declining,
        CASE
            WHEN (
                COUNT_IF(prev_7d_hours > 0 AND (cur_7d_hours - prev_7d_hours) < 0)
                / NULLIF(COUNT_IF(prev_7d_hours > 0), 0)::FLOAT
            ) >= 0.60
            THEN 'BROAD_DECLINE'
            ELSE 'HANDFUL_DRIVING_DECLINE'
        END AS decline_pattern
    FROM asset_7d_compare
    GROUP BY 1
),

/* Handful % + array (top 3 decliners by dip) */
ranked_decliners AS (
    SELECT
        a.GEOFENCE_ID,
        a.ASSET_ID,
        (COALESCE(a.cur_7d_hours,0) - COALESCE(a.prev_7d_hours,0)) AS dip_hours,
        ROW_NUMBER() OVER (
            PARTITION BY a.GEOFENCE_ID
            ORDER BY (COALESCE(a.cur_7d_hours,0) - COALESCE(a.prev_7d_hours,0)) ASC
        ) AS dip_rank
    FROM asset_7d_compare a
    WHERE a.prev_7d_hours > 0
      AND (COALESCE(a.cur_7d_hours,0) - COALESCE(a.prev_7d_hours,0)) < 0
),

handful_summary AS (
    SELECT
        GEOFENCE_ID,
        SUM(ABS(dip_hours)) AS total_dip_abs,
        SUM(CASE WHEN dip_rank <= 3 THEN ABS(dip_hours) ELSE 0 END) AS handful_dip_abs,
        ARRAY_AGG(CASE WHEN dip_rank <= 3 THEN ASSET_ID END)
            WITHIN GROUP (ORDER BY dip_rank) AS handful_assets_array
    FROM ranked_decliners
    GROUP BY 1
)

SELECT
    t.GEOFENCE_ID,
    t.GEOFENCE_NAME,
    t.COMPANY_ID,
    t.snapshot_date,
    t.avg_7d,
    t.prev_7d_avg,
    t.pct_chg_7d,
    t.est_weekly_drop,
    t.est_weeks_to_zero,
    t.projected_zero_date,
    t.top2_concentration,
    t.geofence_status,

    CASE
        WHEN t.geofence_status = 'EOL'
        THEN 'Usage is trending down and appears to be end-of-life. Confirm job completion; reallocate remaining assets; archive/delete the geofence when appropriate.'
        WHEN t.geofence_status = 'MATERIAL_DECLINE'
        THEN 'Material decline detected. Determine if this is jobsite-wide or driven by a small set of assets. If handful-driven, focus on returning those assets (or equivalents) to the geofence or investigate why they are no longer utilized here.'
        ELSE 'Decline detected but not yet material. Monitor weekly trend and asset distribution.'
    END AS recommended_action,

    b.prev_active_asset_count,
    b.declining_asset_count,
    b.pct_assets_declining,
    b.decline_pattern,

    CASE
        WHEN b.decline_pattern = 'HANDFUL_DRIVING_DECLINE'
        THEN (h.handful_dip_abs / NULLIF(h.total_dip_abs,0))::FLOAT
        ELSE NULL
    END AS handful_pct_of_total_dip,

    CASE
        WHEN b.decline_pattern = 'HANDFUL_DRIVING_DECLINE'
        THEN h.handful_assets_array
        ELSE NULL
    END AS handful_assets_array

FROM top5 t
LEFT JOIN breadth b USING (GEOFENCE_ID)
LEFT JOIN handful_summary h USING (GEOFENCE_ID)
ORDER BY (t.avg_7d * ABS(t.pct_chg_7d)) DESC, t.GEOFENCE_ID
          ;;
  }


  dimension: geofence_id { type: string sql: ${TABLE}.GEOFENCE_ID ;; }
  dimension: geofence_name { type: string sql: ${TABLE}.GEOFENCE_NAME ;; }















}
