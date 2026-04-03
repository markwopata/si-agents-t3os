view: v_dim_date {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_DATE" ;;

  dimension: current_month {
    type: yesno
    sql: ${TABLE}."CURRENT_MONTH" ;;
  }
  dimension: date {
    type: date_raw
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
  dimension: dt_key {
    type: number
    sql: ${TABLE}."DT_KEY" ;;
  }
  dimension: last_120_days {
    type: yesno
    sql: ${TABLE}."LAST_120_DAYS" ;;
  }
  dimension: last_180_days {
    type: yesno
    sql: ${TABLE}."LAST_180_DAYS" ;;
  }
  dimension: last_365_days {
    type: yesno
    sql: ${TABLE}."LAST_365_DAYS" ;;
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
