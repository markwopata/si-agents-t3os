view: dim_dates_bi {

  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_DATES_BI" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_formatted {
    group_label: "HTML Formatted Date"
    label: "Date"
    type: date
    sql: ${date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: date_key {
    type: string
    sql: ${TABLE}."DATE_KEY" ;;
    hidden: yes
    primary_key: yes
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

  dimension: is_current_date {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_DATE" ;;
  }

  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }

  dimension: is_first_day_of_month {
    type: yesno
    sql: ${TABLE}."IS_FIRST_DAY_OF_MONTH" ;;
  }

  dimension: is_last_120_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_120_DAYS" ;;
  }

  dimension: is_last_180_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_180_DAYS" ;;
  }

  dimension: is_last_28_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_28_DAYS" ;;
  }

  dimension: is_last_30_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_30_DAYS" ;;
  }

  dimension: is_last_31_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_31_DAYS" ;;
  }

  dimension: is_last_60_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_60_DAYS" ;;
  }

  dimension: is_last_7_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_7_DAYS" ;;
  }

  dimension: is_last_90_days {
    type: yesno
    sql: ${TABLE}."IS_LAST_90_DAYS" ;;
  }

  dimension: is_last_day_of_month {
    type: yesno
    sql: ${TABLE}."IS_LAST_DAY_OF_MONTH" ;;
  }

  dimension: is_month_to_date {
    type: yesno
    sql: ${TABLE}."IS_MONTH_TO_DATE" ;;
  }

  dimension: is_prior_month {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_MONTH" ;;
  }

  dimension: is_prior_month_to_date {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_MONTH_TO_DATE" ;;
  }

  dimension: is_prior_quarter {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_QUARTER" ;;
  }

  dimension: is_prior_year_to_date {
    type: yesno
    sql: ${TABLE}."IS_PRIOR_YEAR_TO_DATE" ;;
  }

  dimension: is_quarter_to_date {
    type: yesno
    sql: ${TABLE}."IS_QUARTER_TO_DATE" ;;
  }

  dimension: is_trailing_12_months {
    type: yesno
    sql: ${TABLE}."IS_TRAILING_12_MONTHS" ;;
  }

  dimension: is_weekday {
    type: yesno
    sql: ${TABLE}."IS_WEEKDAY" ;;
  }

  dimension: is_year_to_date {
    type: yesno
    sql: ${TABLE}."IS_YEAR_TO_DATE" ;;
  }

  dimension: month {
    type: number
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: next_period {
    type: string
    sql: ${TABLE}."NEXT_PERIOD" ;;
  }

  dimension: period {
    type: string
    sql: ${TABLE}."PERIOD" ;;
  }

  dimension: prior_period {
    type: string
    sql: ${TABLE}."PRIOR_PERIOD" ;;
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

  measure: count {
    type: count
    drill_fields: [month_name]
  }
}
