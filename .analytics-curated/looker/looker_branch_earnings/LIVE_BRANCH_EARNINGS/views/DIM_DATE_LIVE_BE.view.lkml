view: DIM_DATE_LIVE_BE {
  sql_table_name: "BRANCH_EARNINGS"."DIM_DATE_LIVE_BE" ;;

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }
  dimension: day {
    type: number
    sql: ${TABLE}."DAY" ;;
  }
  dimension: day_of_week {
    type: number
    sql: ${TABLE}."DAY_OF_WEEK" ;;
  }
  dimension: day_of_year {
    type: number
    sql: ${TABLE}."DAY_OF_YEAR" ;;
  }
  dimension: has_data {
    type: yesno
    sql: ${TABLE}."HAS_DATA" ;;
  }
  dimension: has_data_time_entry {
    type: yesno
    sql: ${TABLE}."HAS_DATA_TIME_ENTRY" ;;
  }
  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }
  dimension: month_to_date {
    type: yesno
    sql: ${TABLE}."MONTH_TO_DATE" ;;
  }
  dimension: next_period {
    type: string
    sql: ${TABLE}."NEXT_PERIOD" ;;
  }
  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }
  dimension: prior_month {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH" ;;
  }
  dimension: prior_month_to_date {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH_TO_DATE" ;;
  }
  dimension: prior_period {
    type: string
    sql: ${TABLE}."PRIOR_PERIOD" ;;
  }
  dimension: prior_quarter {
    type: yesno
    sql: ${TABLE}."PRIOR_QUARTER" ;;
  }
  dimension: quarter_to_date {
    type: yesno
    sql: ${TABLE}."QUARTER_TO_DATE" ;;
  }
  dimension_group: record_created_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }
  dimension_group: record_modified_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }
  dimension: week_of_year {
    type: number
    sql: ${TABLE}."WEEK_OF_YEAR" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: year_month {
    type: string
    sql: ${TABLE}."YEAR_MONTH" ;;
  }
  dimension: year_to_date {
    type: yesno
    sql: ${TABLE}."YEAR_TO_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [month_name]
  }
}
