view: performing_geofences {



  derived_table: {
    sql:



-- Super Geofences (High usage + Consistent + Trending up) + Asset recommendations
-- Company: 109154 | Window: last 365 days
-- Outputs: Top 5 geofences + top 3 asset_ids + approx boost range X%–Y% if adding ONE of them

WITH base AS (
    SELECT *
    FROM business_intelligence.triage.stg_t3__geofence_asset_usage
    WHERE COMPANY_ID = 109154
      AND USAGE_DATE >= DATEADD(day, -365, CURRENT_DATE())
      AND COALESCE(HOURS_IN_GEOFENCE, 0) > 0
),

/* -----------------------------
   Geofence-level volume + consistency
------------------------------*/
geofence_metrics AS (
    SELECT
        GEOFENCE_ID,
        MAX(GEOFENCE_NAME) AS GEOFENCE_NAME,
        SUM(HOURS_IN_GEOFENCE) AS total_hours_365,
        COUNT(DISTINCT USAGE_DATE) AS active_days,
        COUNT(DISTINCT USAGE_DATE) / 365.0 AS day_coverage_ratio
    FROM base
    GROUP BY 1
),

/* -----------------------------
   Avg site daily hours (denominator for lift)
------------------------------*/
geofence_daily AS (
    SELECT
        GEOFENCE_ID,
        USAGE_DATE,
        SUM(HOURS_IN_GEOFENCE) AS total_hours_day
    FROM base
    GROUP BY 1,2
),

geofence_avg_daily AS (
    SELECT
        GEOFENCE_ID,
        AVG(total_hours_day) AS avg_site_daily_hours
    FROM geofence_daily
    GROUP BY 1
),

/* -----------------------------
   Trend signal from PCT_CHG_7D/30D/90D
   Use avg across rows; clamp to [-1, 1] to avoid outliers dominating
------------------------------*/
geofence_trend AS (
    SELECT
        GEOFENCE_ID,

        -- Weighted trend: 30D and 90D are less noisy than 7D
        LEAST(
          GREATEST(
            (0.20 * COALESCE(AVG(PCT_CHG_7D), 0))
          + (0.40 * COALESCE(AVG(PCT_CHG_30D), 0))
          + (0.40 * COALESCE(AVG(PCT_CHG_90D), 0)),
          -1
          ),
        1
        ) AS trend_score
    FROM base
    GROUP BY 1
),

/* -----------------------------
   Combine + super score
------------------------------*/
combined AS (
    SELECT
        gm.GEOFENCE_ID,
        gm.GEOFENCE_NAME,
        gm.total_hours_365,
        gm.active_days,
        gm.day_coverage_ratio,
        gad.avg_site_daily_hours,
        gt.trend_score,

        PERCENT_RANK() OVER (ORDER BY gm.total_hours_365)      AS pr_total_hours,
        PERCENT_RANK() OVER (ORDER BY gm.day_coverage_ratio)   AS pr_coverage,
        PERCENT_RANK() OVER (ORDER BY gt.trend_score)          AS pr_trend,

        (
          PERCENT_RANK() OVER (ORDER BY gm.total_hours_365)    * 0.50
        + PERCENT_RANK() OVER (ORDER BY gm.day_coverage_ratio) * 0.30
        + PERCENT_RANK() OVER (ORDER BY gt.trend_score)        * 0.20
        ) AS super_score
    FROM geofence_metrics gm
    JOIN geofence_avg_daily gad USING (GEOFENCE_ID)
    JOIN geofence_trend gt USING (GEOFENCE_ID)
),

super_geofences AS (
    SELECT *
    FROM combined
    QUALIFY ROW_NUMBER() OVER (ORDER BY super_score DESC) <= 5
),

/* -----------------------------
   Top 3 asset_ids per super geofence
------------------------------*/
asset_metrics AS (
    SELECT
        GEOFENCE_ID,
        ASSET_ID,
        SUM(HOURS_IN_GEOFENCE) AS asset_total_hours_365,
        COUNT(DISTINCT USAGE_DATE) AS asset_active_days,
        SUM(HOURS_IN_GEOFENCE) / NULLIF(COUNT(DISTINCT USAGE_DATE), 0) AS asset_avg_hours_per_active_day
    FROM base
    GROUP BY 1,2
),

ranked_assets AS (
    SELECT
        am.*,
        ROW_NUMBER() OVER (
            PARTITION BY am.GEOFENCE_ID
            ORDER BY am.asset_total_hours_365 DESC
        ) AS asset_rank
    FROM asset_metrics am
),

top3_assets AS (
    SELECT *
    FROM ranked_assets
    WHERE asset_rank <= 3
),

/* -----------------------------
   Lift range X–Y for adding ONE asset:
   lift(asset) = asset_avg_hours_per_active_day / avg_site_daily_hours
------------------------------*/
top3_with_lift AS (
    SELECT
        sg.GEOFENCE_ID,
        sg.GEOFENCE_NAME,
        sg.total_hours_365,
        sg.active_days,
        sg.day_coverage_ratio,
        sg.avg_site_daily_hours,
        sg.trend_score,
        sg.super_score,

        a.ASSET_ID,
        a.asset_rank,
        a.asset_total_hours_365,
        a.asset_active_days,
        a.asset_avg_hours_per_active_day,

        a.asset_avg_hours_per_active_day / NULLIF(sg.avg_site_daily_hours, 0) AS lift_pct_if_added
    FROM super_geofences sg
    JOIN top3_assets a
      ON sg.GEOFENCE_ID = a.GEOFENCE_ID
),

geofence_rollup AS (
    SELECT
        GEOFENCE_ID,
        GEOFENCE_NAME,
        total_hours_365,
        active_days,
        day_coverage_ratio,
        avg_site_daily_hours,
        trend_score,
        super_score,

        LISTAGG(ASSET_ID::STRING, ', ') WITHIN GROUP (ORDER BY asset_rank) AS recommended_asset_ids,

        -- Range for "add ONE of these assets"
        MIN(lift_pct_if_added) AS approx_boost_pct_low,
        MAX(lift_pct_if_added) AS approx_boost_pct_high
    FROM top3_with_lift
    GROUP BY 1,2,3,4,5,6,7,8
)

SELECT *
FROM geofence_rollup
ORDER BY super_score DESC
          ;;
  }


  dimension: geofence_id { type: string sql: ${TABLE}.GEOFENCE_ID ;; }
  dimension: geofence_name { type: string sql: ${TABLE}.GEOFENCE_NAME ;; }







  }
