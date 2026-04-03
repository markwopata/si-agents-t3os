view: dim_dates_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_DATES_FLEET_OPT" ;;

  dimension_group: date_month_end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MONTH_END" ;;
  }
  dimension_group: date_month_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MONTH_START" ;;
  }
  dimension: dt_current_month {
    type: yesno
    sql: ${TABLE}."DT_CURRENT_MONTH" ;;
  }
  dimension_group: dt_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DT_DATE" ;;
  }
  dimension: dt_day {
    type: number
    sql: ${TABLE}."DT_DAY" ;;
  }
  dimension: dt_day_of_week {
    type: number
    sql: ${TABLE}."DT_DAY_OF_WEEK" ;;
  }
  dimension: dt_day_of_year {
    type: number
    sql: ${TABLE}."DT_DAY_OF_YEAR" ;;
  }
  dimension: dt_key {
    type: string
    sql: ${TABLE}."DT_KEY" ;;
  }
  dimension: dt_last_120_days {
    type: yesno
    sql: ${TABLE}."DT_LAST_120_DAYS" ;;
  }
  dimension: dt_last_180_days {
    type: yesno
    sql: ${TABLE}."DT_LAST_180_DAYS" ;;
  }
  dimension: dt_last_30_days {
    type: yesno
    sql: ${TABLE}."DT_LAST_30_DAYS" ;;
  }
  dimension: dt_last_60_days {
    type: yesno
    sql: ${TABLE}."DT_LAST_60_DAYS" ;;
  }
  dimension: dt_last_90_days {
    type: yesno
    sql: ${TABLE}."DT_LAST_90_DAYS" ;;
  }
  dimension: dt_month {
    type: number
    sql: ${TABLE}."DT_MONTH" ;;
  }
  dimension: dt_month_name {
    type: string
    sql: ${TABLE}."DT_MONTH_NAME" ;;
  }
  dimension: dt_month_to_date {
    type: yesno
    sql: ${TABLE}."DT_MONTH_TO_DATE" ;;
  }
  dimension: dt_next_period {
    type: string
    sql: ${TABLE}."DT_NEXT_PERIOD" ;;
  }
  dimension: dt_period {
    type: string
    sql: ${TABLE}."DT_PERIOD" ;;
  }
  dimension: dt_prior_month {
    type: yesno
    sql: ${TABLE}."DT_PRIOR_MONTH" ;;
  }
  dimension: dt_prior_month_to_date {
    type: yesno
    sql: ${TABLE}."DT_PRIOR_MONTH_TO_DATE" ;;
  }
  dimension: dt_prior_period {
    type: string
    sql: ${TABLE}."DT_PRIOR_PERIOD" ;;
  }
  dimension: dt_prior_quarter {
    type: yesno
    sql: ${TABLE}."DT_PRIOR_QUARTER" ;;
  }
  dimension: dt_prior_year_to_date {
    type: yesno
    sql: ${TABLE}."DT_PRIOR_YEAR_TO_DATE" ;;
  }
  dimension: dt_quarter_to_date {
    type: yesno
    sql: ${TABLE}."DT_QUARTER_TO_DATE" ;;
  }
  dimension_group: dt_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DT_RECORDTIMESTAMP" ;;
  }
  dimension: dt_week_of_year {
    type: number
    sql: ${TABLE}."DT_WEEK_OF_YEAR" ;;
  }
  dimension: dt_weekday {
    type: yesno
    sql: ${TABLE}."DT_WEEKDAY" ;;
  }
  dimension: dt_year {
    type: number
    sql: ${TABLE}."DT_YEAR" ;;
  }
  dimension: dt_year_month {
    type: string
    sql: ${TABLE}."DT_YEAR_MONTH" ;;
  }
  dimension: dt_year_to_date {
    type: yesno
    sql: ${TABLE}."DT_YEAR_TO_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [dt_month_name]
  }
}
