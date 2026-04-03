view: dim_timeframe_windows_historic {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_TIMEFRAME_WINDOWS_HISTORIC" ;;

  dimension: days_in_period {
    type: number
    sql: ${TABLE}."DAYS_IN_PERIOD" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: is_last_calendar_12_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_12_MONTHS" ;;
  }
  dimension: is_last_calendar_18_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_18_MONTHS" ;;
  }
  dimension: is_last_calendar_24_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_24_MONTHS" ;;
  }
  dimension: is_last_calendar_2_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_2_MONTHS" ;;
  }
  dimension: is_last_calendar_2_quarters {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_2_QUARTERS" ;;
  }
  dimension: is_last_calendar_2_years {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_2_YEARS" ;;
  }
  dimension: is_last_calendar_3_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_3_MONTHS" ;;
  }
  dimension: is_last_calendar_3_quarters {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_3_QUARTERS" ;;
  }
  dimension: is_last_calendar_4_quarters {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_4_QUARTERS" ;;
  }
  dimension: is_last_calendar_6_months {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_6_MONTHS" ;;
  }
  dimension: is_last_calendar_month {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_MONTH" ;;
  }
  dimension: is_last_calendar_quarter {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_QUARTER" ;;
  }
  dimension: is_last_calendar_year {
    type: yesno
    sql: ${TABLE}."IS_LAST_CALENDAR_YEAR" ;;
  }
  dimension: is_more_than_24_calendar_months {
    type: yesno
    sql: ${TABLE}."IS_MORE_THAN_24_CALENDAR_MONTHS" ;;
  }
  dimension: is_more_than_2_calendar_years {
    type: yesno
    sql: ${TABLE}."IS_MORE_THAN_2_CALENDAR_YEARS" ;;
  }
  dimension: is_more_than_4_calendar_quarters {
    type: yesno
    sql: ${TABLE}."IS_MORE_THAN_4_CALENDAR_QUARTERS" ;;
  }
  dimension_group: run {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RUN_DATE" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: tf_key {
    type: string
    sql: ${TABLE}."TF_KEY" ;;
  }
  dimension: timeframe {
    type: string
    sql: ${TABLE}."TIMEFRAME" ;;
  }
  measure: count {
    type: count
  }
}
