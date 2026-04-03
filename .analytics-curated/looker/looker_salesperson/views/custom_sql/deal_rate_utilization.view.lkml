view: deal_rate_utilization {
  derived_table: {
    sql:
      with time_ut as (SELECT EQUIPMENT_CLASS_ID,
                              rr.district,
                              ROUND(SUM(h.rental_oec) / NULLIF(SUM(h.in_fleet_oec), 0), 4) AS time_ut --typical time ute calc
                       FROM FLEET_OPTIMIZATION.GOLD.UTILIZATION_ASSET_MARKET_HISTORICAL h
                                LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC dt ON dt.TF_KEY = h.TF_KEY
                                LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSETS a ON a.ASSET_ID = h.ASSET_ID
                                left join ANALYTICS.RATE_ACHIEVEMENT.RATE_REGIONS rr on rr.MARKET_ID = h.MARKET_ID
                       WHERE dt.TIMEFRAME = 'monthly'
                         and datediff(months, dt.start_date, current_date) < 3
                       group by 1, 2)
      select dr.DISTRICT,
             rr.REGION_NAME,
             count(case when tu.time_ut >= .65 then dr.DISCOUNT_RATE_ID else null end) as high_ut_count,
             count(dr.DISCOUNT_RATE_ID)                                                as active_count,
             high_ut_count/active_count as high_ut_percent
      from RATE_ACHIEVEMENT.DISCOUNT_RATES dr
               left join time_ut tu on dr.EQUIPMENT_CLASS_ID = tu.EQUIPMENT_CLASS_ID and dr.DISTRICT = tu.DISTRICT
      left join (select distinct DISTRICT, REGION_NAME from RATE_ACHIEVEMENT.RATE_REGIONS) rr on dr.DISTRICT = rr.DISTRICT
      where dr.ACTIVE
      group by 1, 2
    ;;
  }

  dimension: district {
    primary_key: yes
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: high_ut_count {
    type: number
    sql: ${TABLE}."HIGH_UT_COUNT" ;;
  }

  dimension: active_count {
    type: number
    sql: ${TABLE}."ACTIVE_COUNT" ;;
  }

  dimension: high_ut_percent {
    type: number
    sql: ${TABLE}."HIGH_UT_PERCENT" ;;
    drill_fields: [district]
  }

  measure: region_high_ut_count {
    type: sum
    sql: ${high_ut_count} ;;
    drill_fields: [district, high_ut_count, active_count, high_ut_percent]
  }

  measure: region_active_count {
    type: sum
    sql: ${active_count} ;;
  }
}
