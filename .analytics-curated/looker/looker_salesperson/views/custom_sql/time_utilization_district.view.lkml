view: time_utilization_district {
  derived_table: {
    sql:
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
            AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))

      SELECT EQUIPMENT_CLASS_ID,
             rr.district,
             ROUND(SUM(h.rental_oec) / NULLIF(SUM(h.in_fleet_oec), 0), 4) AS time_ut --typical time ute calc
      FROM FLEET_OPTIMIZATION.GOLD.UTILIZATION_ASSET_MARKET_HISTORICAL h
               LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC dt ON dt.TF_KEY = h.TF_KEY
               LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS a ON a.ASSET_ID = h.ASSET_ID
               left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on rr.MARKET_ID = h.MARKET_ID
      WHERE dt.TIMEFRAME = 'monthly'
        and datediff(months, dt.start_date, current_date) < 3
        and a.ASSET_ID in (SELECT asset_id from es_assets)
      group by 1, 2
    ;;
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
    sql: ${TABLE}."TIME_UT" ;;
  }
}
