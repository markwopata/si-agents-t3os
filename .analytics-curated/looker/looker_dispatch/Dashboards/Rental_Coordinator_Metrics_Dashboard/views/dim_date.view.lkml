view: dim_date {
  sql_table_name: "ANALYTICS"."CORPORATE_BUDGET"."DIM_DATE"
    ;;

  dimension: accounting_closed {
    type: yesno
    sql: ${TABLE}."ACCOUNTING_CLOSED" ;;
  }

  dimension: date {
    primary_key: yes
    type: string
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_formatted_mdy {
    type: string
    sql: ${TABLE}."DATE_FORMATTED_MDY" ;;
  }

  dimension_group: date_timestamp_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."DATE_TIMESTAMP_END" ;;
  }

  dimension_group: date_timestamp_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.CAST(${TABLE}."DATE_TIMESTAMP_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: date_trunc_month {
    type: string
    sql: ${TABLE}."DATE_TRUNC_MONTH" ;;
  }

  dimension: day_of_month {
    type: number
    sql: ${TABLE}."DAY_OF_MONTH" ;;
  }

  dimension: day_of_week_int {
    type: number
    sql: ${TABLE}."DAY_OF_WEEK_INT" ;;
  }

  dimension: day_of_week_name {
    type: string
    sql: ${TABLE}."DAY_OF_WEEK_NAME" ;;
  }

  dimension: in_last_120_days {
    type: yesno
    sql: ${TABLE}."IN_LAST_120_DAYS" ;;
  }

  dimension: in_last_180_days {
    type: yesno
    sql: ${TABLE}."IN_LAST_180_DAYS" ;;
  }

  dimension: in_last_30_days {
    type: yesno
    sql: ${TABLE}."IN_LAST_30_DAYS" ;;
  }

  dimension: in_last_60_days {
    type: yesno
    sql: ${TABLE}."IN_LAST_60_DAYS" ;;
  }

  dimension: in_last_90_days {
    type: yesno
    sql: ${TABLE}."IN_LAST_90_DAYS" ;;
  }

  dimension: is_current_month {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTH" ;;
  }

  dimension: is_current_year {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_YEAR" ;;
  }

  dimension: is_holiday {
    type: yesno
    sql: ${TABLE}."IS_HOLIDAY" ;;
  }

  dimension: is_last_month {
    type: yesno
    sql: ${TABLE}."IS_LAST_MONTH" ;;
  }

  dimension: is_weekday {
    type: yesno
    sql: ${TABLE}."IS_WEEKDAY" ;;
  }

  dimension: month_int {
    type: number
    sql: ${TABLE}."MONTH_INT" ;;
  }

  dimension: month_name {
    type: string
    sql: ${TABLE}."MONTH_NAME" ;;
  }

  dimension: month_year {
    order_by_field: date_trunc_month
    type: string
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: week_int {
    type: number
    sql: ${TABLE}."WEEK_INT" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  measure: count {
    type: count
    drill_fields: [month_name, day_of_week_name]
  }
}
