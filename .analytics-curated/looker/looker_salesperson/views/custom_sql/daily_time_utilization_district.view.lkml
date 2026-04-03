view: daily_time_utilization_district {
    derived_table: {
      sql:
      -- Generate a daily calendar for the last 2 years
with es_assets as (select a.ASSET_ID
    from ES_WAREHOUSE.PUBLIC.ASSETS a
    left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on a.MARKET_ID = rr.MARKET_ID
    left join ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec on a.EQUIPMENT_CLASS_ID = ec.EQUIPMENT_CLASS_ID
    WHERE a.COMPANY_ID in (
                select company_id
                from ANALYTICS.PUBLIC.ES_COMPANIES
                where owned = true)
    --CONTRACTOR OWNED/OWN PROGRAM
    OR a.COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
        FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
        JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
            ON VPP.ASSET_ID = AA.ASSET_ID
        WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31'))),


    calendar_days AS (
  SELECT DATEADD(DAY, -seq4(), CURRENT_DATE) AS calendar_date
  FROM TABLE(GENERATOR(ROWCOUNT => 730)) -- Last 2 years (730 days)
),

-- Explode on-rent days
on_rent_days AS (
  SELECT
    ea.asset_id,
    aa.equipment_class_id,
    cd.calendar_date
  FROM fleet_optimization.intermediate.int_asset_rental_assignments ea
  JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa ON aa.asset_id = ea.asset_id
  JOIN calendar_days cd
    ON cd.calendar_date BETWEEN ea.rental_start_date AND COALESCE(ea.rental_end_date, CURRENT_DATE)
),

-- All asset days based on assignment windows (denominator)
all_asset_days AS (
  SELECT
    a.asset_id,
    ec.equipment_class_id,
    cd.calendar_date,
    pit.rental_branch_id
  FROM ES_WAREHOUSE.PUBLIC.ASSETS a
  JOIN ES_WAREHOUSE.PUBLIC.EQUIPMENT_CLASSES ec ON ec.equipment_class_id = a.equipment_class_id
  JOIN FLEET_OPTIMIZATION.GOLD.DIM_ASSET_RSP_PIT pit ON pit.asset_id = a.asset_id
  JOIN calendar_days cd ON cd.calendar_date BETWEEN pit.start_window AND COALESCE(pit.end_window, CURRENT_DATE)
),

-- Join to mark if asset was on rent that day
asset_day_flags AS (
  SELECT
    d.calendar_date,
    d.equipment_class_id,
    rr.district,
    d.asset_id,
    CASE WHEN r.asset_id IS NOT NULL THEN 1 ELSE 0 END AS on_rent_flag
  FROM all_asset_days d
  LEFT JOIN on_rent_days r
    ON d.asset_id = r.asset_id AND d.calendar_date = r.calendar_date
  LEFT JOIN ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr
    ON rr.market_id = d.rental_branch_id
  WHERE d.ASSET_ID in (SELECT asset_id from es_assets)
)
-- Final aggregation: time utilization
SELECT
calendar_date as day,
  equipment_class_id,
  district,
  ROUND(SUM(on_rent_flag) * 1.0 / COUNT(*), 4) AS time_ut
FROM asset_day_flags
GROUP BY 1,2,3
ORDER BY 1 DESC, 2
        ;;
    }


    dimension_group: calendar {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."DAY" ;;
    }

    dimension: equipment_class_id {
      type: number
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

    dimension: district {
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: time_ut {
      type: number
      value_format: "0%"
      sql: ${TABLE}."TIME_UT" ;;
    }
  }
