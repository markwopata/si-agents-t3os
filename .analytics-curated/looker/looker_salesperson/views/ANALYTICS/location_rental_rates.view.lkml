view: location_rental_rates {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."LOCATION_RENTAL_RATES" ;;

  dimension_group: contract_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CONTRACT_EXPIRATION_DATE" ;;
  }
  dimension: contract_length_in_years {
    type: number
    sql: ${TABLE}."CONTRACT_LENGTH_IN_YEARS" ;;
  }
  dimension_group: effective_agreed_upon {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EFFECTIVE_AGREED_UPON_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: effective_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EFFECTIVE_START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }
  dimension_group: rate_achievement_expiration {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RATE_ACHIEVEMENT_EXPIRATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
