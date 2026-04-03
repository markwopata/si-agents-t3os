view: dim_date {
  sql_table_name: "CORPORATE_BUDGET"."V_DIM_DATE"
    ;;

  dimension: date {
    type: string
    sql: ${TABLE}."DATE" ;;
  }

  dimension: date_formatted_mdy {
    type: string
    sql: ${TABLE}."DATE_FORMATTED_MDY" ;;
  }

  dimension: date_trunc_month {
    type: string
    sql: ${TABLE}."DATE_TRUNC_MONTH" ;;
  }

  dimension: month_year {
    order_by_field: date
    type: string
    sql: ${TABLE}."MONTH_YEAR" ;;
  }

  dimension: accounting_closed {
    type: yesno
    sql: ${TABLE}."ACCOUNTING_CLOSED" ;;
  }

  dimension_group: date_timestamp_end {
    type: time
    sql: ${TABLE}."DATE_TIMESTAMP_END" ;;
  }

  dimension_group: date_timestamp_start {
    type: time
    sql: ${TABLE}."DATE_TIMESTAMP_START" ;;
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

  dimension: quarter {
    type: number
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: week_int {
    type: number
    sql: ${TABLE}."WEEK_INT" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: year_filter {
    type: string
    sql: CONCAT('Budget Year - ', ${year}) ;;
  }

  dimension: max_published_quarter {
    type:  number
    sql:  ${TABLE}."MAX_PUBLISHED_QUARTER" ;;
  }


  measure: count {
    type: count
    drill_fields: [day_of_week_name, month_name]
  }
}
