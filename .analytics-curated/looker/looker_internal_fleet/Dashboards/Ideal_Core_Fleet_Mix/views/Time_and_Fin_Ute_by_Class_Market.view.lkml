view: time_and_fin_ute_by_class_market {
    derived_table: {
      sql:
              Select
            dt.END_DATE as date,
--             a.ASSET_ID,
            a.EQUIPMENT_CLASS_ID,
            h.MARKET_ID,
--             f.DAYS_IN_FLEET,
            dt.DAYS_IN_PERIOD,
--             d.DAYS_ON_RENT,
--             r.revenue,
--             h.oec_adjusted,
--             h.rental_oec as rental_oec_sum,
--             h.in_fleet_oec as in_fleet_oec_sum
            sum(r.revenue) as revenue_sum,
            sum(h.oec_adjusted) as oec_adjusted_sum,
            ifnull(round(((sum(r.revenue)*365)/dt.days_in_period)/sum(h.oec_adjusted),4),0) as financial_utilization,
            sum(h.rental_oec) as rental_oec_sum,
            sum(h.in_fleet_oec) as in_fleet_oec_sum,
            ifnull(round(rental_oec_sum/in_fleet_oec_sum,4),0) as time_utilization
        FROM FLEET_OPTIMIZATION.GOLD.UTILIZATION_ASSET_MARKET_HISTORICAL h
        left join FLEET_OPTIMIZATION.GOLD.DIM_TIMEFRAME_WINDOWS_HISTORIC dt on dt.TF_KEY = h.TF_KEY
        left join FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_REVENUE_ASSET_MARKET r on r.AGG_REV_CALCULATION_KEY = h.AGG_REV_CALCULATION_KEY and r.TF_KEY = h.TF_KEY
--         left join FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_ON_RENT_ASSET d on d.AGG_DOR_CALCULATION_KEY = h.AGG_DOR_CALCULATION_KEY and d.TF_KEY = h.TF_KEY
--         LEFT JOIN FLEET_OPTIMIZATION.GOLD.DIM_AGG_HISTORIC_DAYS_IN_FLEET_ASSET f on f.TF_KEY = h.TF_KEY and f.AGG_DIF_CALCULATION_KEY = h.AGG_DIF_CALCULATION_KEY
        left join ES_WAREHOUSE.PUBLIC.ASSETS a on a.ASSET_ID = h.ASSET_ID
        WHERE dt.TIMEFRAME = 'monthly'
--         and a.ASSET_ID = 298419
--         and date = '2024-05-31'
        group by 1,2,3,4




--        Select
--        end_date as date,
--        equipment_class_id,
--        branch_name,
--        days_in_period,
--        ifnull(round(((sum(revenue)*365)/days_in_period)/sum(oec_adjusted),4),0) as financial_utilization,
--        sum(rental_oec) as rental_oec_sum,
--        sum(in_fleet_oec) as in_fleet_oec_sum,
--        ifnull(round(rental_oec_sum/in_fleet_oec_sum,4),0) as time_utilization,
--        from data_science_stage.fleet_testing.utilization_historical_working
--        where timeframe = 'monthly'
--        group by 1,2,3,4
--        order by end_date desc
          ;;
    }

    dimension: p_key {
      type: string
      primary_key: yes
      hidden: yes
      sql: CONCAT(${TABLE}."DATE", ${TABLE}."EQUIPMENT_CLASS_ID", ${TABLE}."BRANCH_NAME") ;;
    }

    dimension_group: date {
      type: time
      timeframes: [
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: ${TABLE}."DATE" ;;
    }

    dimension: equipment_class_id {
      type: string
      sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
    }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

    dimension: financial_utilization {
      type: number
      value_format: "0.00%"
      sql: COALESCE(${TABLE}.financial_utilization,0) ;;
    }

    dimension: time_utilization {
      type: number
      value_format: "0.00%"
      sql: COALESCE(${TABLE}.time_utilization,0) ;;
    }

  }
