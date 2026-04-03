view: cdl_headcount_optimization {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."CDL_HEADCOUNT_OPTIMIZATION" ;;

  dimension: active_customers {
    type: number
    sql: ${TABLE}."ACTIVE_CUSTOMERS" ;;
  }
  dimension: average_rent_revenue {
    type: number
    sql: ${TABLE}."AVERAGE_RENT_REVENUE" ;;
  }
  dimension: benchmark_rent_per_cdl {
    type: number
    sql: ${TABLE}."BENCHMARK_RENT_PER_CDL" ;;
  }
  dimension: county_fatalities {
    type: number
    sql: ${TABLE}."COUNTY_FATALITIES" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: environment_score {
    type: number
    sql: ${TABLE}."ENVIRONMENT_SCORE" ;;
  }
  dimension: headcount {
    type: number
    sql: ${TABLE}."HEADCOUNT" ;;
  }
  dimension: market_avg_idle_minutes_per_week {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_AVG_IDLE_MINUTES_PER_WEEK" ;;
  }
  dimension: market_avg_trip_minutes_per_week {
    type: number
    sql: ${TABLE}."MARKET_AVG_TRIP_MINUTES_PER_WEEK" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: month_date {
    type: date_raw
    sql: ${TABLE}."MONTH_DATE" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: state_fatalities {
    type: number
    sql: ${TABLE}."STATE_FATALITIES" ;;
  }
  dimension: vehicle_miles_traveled {
    type: number
    sql: ${TABLE}."VEHICLE_MILES_TRAVELED" ;;
  }
}
