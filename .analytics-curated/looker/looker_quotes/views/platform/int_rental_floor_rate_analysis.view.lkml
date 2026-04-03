view: int_rental_floor_rate_analysis {
  sql_table_name: "PLATFORM"."GOLD"."INT_RENTAL_FLOOR_RATE_ANALYSIS" ;;

  dimension: below_floor_day {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_DAY" ;;
  }
  dimension: below_floor_month {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_MONTH" ;;
  }
  dimension: below_floor_week {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_WEEK" ;;
  }
  dimension: is_below_floor {
    type: yesno
    sql: ${TABLE}."BELOW_FLOOR_DAY"
          OR ${TABLE}."BELOW_FLOOR_MONTH"
          OR ${TABLE}."BELOW_FLOOR_WEEK" ;;
  }
  dimension: floor_day_rate {
    type: number
    sql: ${TABLE}."FLOOR_DAY_RATE" ;;
  }
  dimension: floor_month_rate {
    type: number
    sql: ${TABLE}."FLOOR_MONTH_RATE" ;;
  }
  dimension: floor_rate_source {
    type: string
    sql: ${TABLE}."FLOOR_RATE_SOURCE" ;;
  }
  dimension: floor_week_rate {
    type: number
    sql: ${TABLE}."FLOOR_WEEK_RATE" ;;
  }
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }
  dimension_group: rental_floor_rate_analysis_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RENTAL_FLOOR_RATE_ANALYSIS_RECORDTIMESTAMP" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_source {
    type: string
    sql: ${TABLE}."RENTAL_SOURCE" ;;
  }
  measure: count {
    type: count
  }
}
