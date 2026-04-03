view: cdl_headcount_optimization_temporary {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."CDL_HEADCOUNT_OPTIMIZATION_TEMPORARY" ;;

  dimension: active_cdl_drivers {
    type: number
    sql: ${TABLE}."ACTIVE_CDL_DRIVERS" ;;
  }
  dimension: average_daily_idle_duration {
    type: number
    sql: ${TABLE}."AVERAGE_DAILY_IDLE_DURATION" ;;
  }
  dimension: average_daily_trip_time {
    type: number
    sql: ${TABLE}."AVERAGE_DAILY_TRIP_TIME" ;;
  }
  dimension: average_rent_revenue {
    type: number
    sql: ${TABLE}."AVERAGE_RENT_REVENUE" ;;
  }
  dimension: benchmark_rent_per_cdl {
    type: number
    sql: ${TABLE}."BENCHMARK_RENT_PER_CDL" ;;
  }
  dimension: count_fatalities {
    type: number
    sql: ${TABLE}."COUNT_FATALITIES" ;;
  }
  dimension: environment_score {
    type: number
    sql: ${TABLE}."ENVIRONMENT_SCORE" ;;
  }
  dimension: gap {
    type: number
    sql: round(${TABLE}."GAP") ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_months_open {
    type: number
    sql: ${TABLE}."MARKET_MONTHS_OPEN" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: months_bucket {
    type: string
    sql: ${TABLE}."MONTHS_BUCKET" ;;
  }
  dimension: number_of_active_customers {
    type: number
    sql: ${TABLE}."NUMBER_OF_ACTIVE_CUSTOMERS" ;;
  }
  dimension: predicted_cdls {
    type: number
    sql: round(${TABLE}."PREDICTED_CDLS") ;;
  }
  dimension: predicted_rent {
    type: number
    sql: ${TABLE}."PREDICTED_RENT" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: state_fatalities {
    type: number
    sql: ${TABLE}."STATE_FATALITIES" ;;
  }
  dimension: vmt {
    type: number
    sql: ${TABLE}."VMT" ;;
  }
}
