view: time_windows {


  derived_table: {
    sql:
WITH base AS (
    SELECT
        geofence_id,
        hours,
        CONVERT_TIMEZONE(
            'America/Chicago',
            report_range:start_range::timestamp_tz
        ) AS start_ts_cst
    FROM es_warehouse.public.hourly_asset_geofence_usage
    WHERE asset_id IN (
        SELECT asset_id
        FROM business_intelligence.triage.stg_t3__geofence_asset_usage
        WHERE company_id = 109154
          AND usage_date >= CURRENT_DATE - 365
        GROUP BY asset_id
    )
      AND report_range:start_range::date >= CURRENT_DATE - 365
),

hourly_hist AS (
    SELECT
        geofence_id,
        EXTRACT(HOUR FROM start_ts_cst) AS hod,
        SUM(hours) AS hod_hours
    FROM base
    GROUP BY 1,2
),

geofences AS (
    SELECT DISTINCT geofence_id FROM hourly_hist
),

all_hours AS (
    SELECT seq4() AS hod
    FROM TABLE(GENERATOR(ROWCOUNT => 24))
),

hist_24 AS (
    SELECT
        g.geofence_id,
        h.hod,
        COALESCE(x.hod_hours, 0) AS hod_hours
    FROM geofences g
    CROSS JOIN all_hours h
    LEFT JOIN hourly_hist x
        ON x.geofence_id = g.geofence_id
       AND x.hod = h.hod
),

hist_48 AS (
    SELECT geofence_id, hod, hod_hours FROM hist_24
    UNION ALL
    SELECT geofence_id, hod + 24 AS hod, hod_hours FROM hist_24
),

totals AS (
    SELECT geofence_id, SUM(hod_hours) AS total_hours
    FROM hist_24
    GROUP BY 1
),

lens AS (
    SELECT column1::int AS win_len
    FROM VALUES (1),(2),(3),(4)
),

offsets AS (
    -- offsets 0..3 to support max window length 4
    SELECT column1::int AS off
    FROM VALUES (0),(1),(2),(3)
),

-- compute each (start_hod, win_len) sum via offsets join
window_scores AS (
    SELECT
        s.geofence_id,
        s.hod AS start_hod,
        l.win_len,
        SUM(h.hod_hours) AS window_hours
    FROM hist_24 s
    CROSS JOIN lens l
    JOIN offsets o
        ON o.off < l.win_len
    JOIN hist_48 h
        ON h.geofence_id = s.geofence_id
       AND h.hod = s.hod + o.off
    GROUP BY 1,2,3
),

scored AS (
    SELECT
        w.geofence_id,
        w.start_hod,
        w.win_len,
        w.window_hours,
        t.total_hours,
        CASE WHEN t.total_hours = 0 THEN 0
             ELSE w.window_hours / t.total_hours
        END AS pct_in_window
    FROM window_scores w
    JOIN totals t
      ON t.geofence_id = w.geofence_id
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY geofence_id
            ORDER BY pct_in_window DESC, win_len ASC, start_hod ASC
        ) AS rn
    FROM scored
),


TIME_PERIODS AS
(
SELECT
    geofence_id,
    start_hod AS window_start_hour_cst,
    MOD(start_hod + win_len, 24) AS window_end_hour_cst_exclusive,
    win_len AS window_length_hours,
    total_hours,
    window_hours,
    pct_in_window
FROM ranked
WHERE rn = 1
  AND pct_in_window >= 0.70
  AND win_len <= 4
ORDER BY pct_in_window DESC, window_length_hours ASC
)


SELECT * FROM TIME_PERIODS
WHERE GEOFENCE_ID IN
(
SELECT
    GEOFENCE_ID
FROM business_intelligence.triage.stg_t3__geofence_asset_usage
WHERE company_id = 109154
  AND usage_date >= CURRENT_DATE - 365
GROUP BY ALL
)
          ;;
  }



  dimension: geofence_id { type: string sql: ${TABLE}.GEOFENCE_ID ;; }


  measure: distinct_geofences {
    type: count_distinct
    sql: ${geofence_id} ;;
    value_format_name: decimal_0
  }





}
