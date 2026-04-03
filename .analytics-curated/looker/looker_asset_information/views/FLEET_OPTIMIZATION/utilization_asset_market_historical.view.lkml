view: utilization_asset_market_historical {
 sql_table_name:  "FLEET_OPTIMIZATION"."GOLD"."UTILIZATION_ASSET_MARKET_HISTORICAL"
  ;;
    dimension: utilization_historical_am_key {
      primary_key:  yes
      hidden: yes
      type: string
      sql: ${TABLE}."UTILIZATION_HISTORICAL_AM_KEY"  ;;
    }
    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID"  ;;
    }
    dimension: market_id {
      type: number
      sql: ${TABLE}."MARKET_ID"  ;;
    }
    dimension: asset_company_id {
      type: number
      sql: ${TABLE}."ASSET_COMPANY_ID"  ;;
    }
    dimension: market_company_id {
      type: number
      sql: ${TABLE}."MARKET_COMPANY_ID"  ;;
    }
    measure: asset_count {
      type: sum
      sql: ${TABLE}."ASSET_COUNT"  ;;
    }
    measure: days_on_rent_clean {
      type: sum
      sql: ${TABLE}."DAYS_ON_RENT_CLEAN"  ;;
    }
    measure: revenue_clean {
      type: sum
      sql: ${TABLE}."REVENUE_CLEAN"
      value_format_name: "usd"
      ;;
    }
    measure: oec_used_for_calculations{
      type: sum
      sql: ${TABLE}."OEC_USED_FOR_CALCULATIONS"
              value_format_name: "usd"
              ;;
    }
    measure: rental_oec{
      type: sum
      sql: ${TABLE}."RENTAL_OEC"
              value_format_name: "usd"
              ;;
    }
    measure: in_fleet_oec{
      type: sum
      sql: ${TABLE}."IN_FLEET_OEC"
              value_format_name: "usd"
              ;;
    }
    measure: oec_adjusted{
      type: sum
      sql: ${TABLE}."OEC_ADJUSTED"
              value_format_name: "usd"
              ;;
    }
    measure: unit_utilization{
      type: average
      sql: ${TABLE}."UNIT_UTILIZATION"
              ;;
    }
    measure: time_utilization{
      type: average
      sql: ${TABLE}."TIME_UTILIZATION"
        ;;
    }
    measure: financial_utilization{
      type: average
      sql: ${TABLE}."FINANCIAL_UTILIZATION"
        ;;
    }
  }
