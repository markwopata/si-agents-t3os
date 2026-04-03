
view: platform_gold_v_dates {
  sql_table_name: platform.gold.v_dates ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date_key {
    type: string
    sql: ${TABLE}."DATE_KEY" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: prior_period {
    type: string
    sql: ${TABLE}."PRIOR_PERIOD" ;;
  }

  dimension: next_period {
    type: string
    sql: ${TABLE}."NEXT_PERIOD" ;;
  }

  dimension: year_month {
    type: string
    sql: ${TABLE}."YEAR_MONTH" ;;
  }

  dimension: day {
    type: number
    sql: ${TABLE}."DAY" ;;
  }

  dimension: day_of_week {
    type: number
    sql: ${TABLE}."DAY_OF_WEEK" ;;
  }

  dimension: week_of_year {
    type: number
    sql: ${TABLE}."WEEK_OF_YEAR" ;;
  }

  dimension: day_of_year {
    type: number
    sql: ${TABLE}."DAY_OF_YEAR" ;;
  }

  dimension: weekday {
    type: yesno
    sql: ${TABLE}."WEEKDAY" ;;
  }

  dimension: last_30_days {
    type: yesno
    sql: ${TABLE}."LAST_30_DAYS" ;;
  }

  dimension: last_60_days {
    type: yesno
    sql: ${TABLE}."LAST_60_DAYS" ;;
  }

  dimension: last_90_days {
    type: yesno
    sql: ${TABLE}."LAST_90_DAYS" ;;
  }

  dimension: last_120_days {
    type: yesno
    sql: ${TABLE}."LAST_120_DAYS" ;;
  }

  dimension: last_180_days {
    type: yesno
    sql: ${TABLE}."LAST_180_DAYS" ;;
  }

  dimension: year_to_date {
    type: yesno
    sql: ${TABLE}."YEAR_TO_DATE" ;;
  }

  dimension: quarter_to_date {
    type: yesno
    sql: ${TABLE}."QUARTER_TO_DATE" ;;
  }

  dimension: month_to_date {
    type: yesno
    sql: ${TABLE}."MONTH_TO_DATE" ;;
  }

  dimension: prior_year_to_date {
    type: yesno
    sql: ${TABLE}."PRIOR_YEAR_TO_DATE" ;;
  }

  dimension: prior_month_to_date {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH_TO_DATE" ;;
  }

  dimension: prior_month {
    type: yesno
    sql: ${TABLE}."PRIOR_MONTH" ;;
  }

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }

  dimension: prior_quarter {
    type: yesno
    sql: ${TABLE}."PRIOR_QUARTER" ;;
  }

  dimension_group: date_recordtimestamp {
    type: time
    sql: ${TABLE}."DATE_RECORDTIMESTAMP" ;;
  }

  set: detail {
    fields: [
        date_key,
  date,
  year,
  month,
  month_name,
  period,
  prior_period,
  next_period,
  year_month,
  day,
  day_of_week,
  week_of_year,
  day_of_year,
  weekday,
  last_30_days,
  last_60_days,
  last_90_days,
  last_120_days,
  last_180_days,
  year_to_date,
  quarter_to_date,
  month_to_date,
  prior_year_to_date,
  prior_month_to_date,
  prior_month,
  current_month,
  prior_quarter,
  date_recordtimestamp_time
    ]
  }
}
