view: dim_dates {
  sql_table_name: "PLATFORM"."GOLD"."V_DATES" ;;

  dimension: date_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."DATE_KEY" ;;
  }

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }

  dimension: date {
    type: date
    convert_tz: no
    sql: ${TABLE}."DATE" ;;
  }

  dimension_group: date_recordtimestamp {
    type: time
    convert_tz: no
    hidden: yes
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."DATE_RECORDTIMESTAMP" ;;
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

  dimension: month {
    type: string
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

  dimension: prior_year_to_date {
    type: yesno
    sql: ${TABLE}."PRIOR_YEAR_TO_DATE" ;;
  }

  dimension: quarter_to_date {
    type: yesno
    sql: ${TABLE}."QUARTER_TO_DATE" ;;
  }

  dimension: week_of_year {
    type: number
    sql: ${TABLE}."WEEK_OF_YEAR" ;;
  }

  dimension: weekday {
    type: yesno
    sql: ${TABLE}."WEEKDAY" ;;
  }

  dimension: year {
    type: string
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

}
