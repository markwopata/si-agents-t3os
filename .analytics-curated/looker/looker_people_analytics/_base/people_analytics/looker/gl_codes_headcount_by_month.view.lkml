view: gl_codes_headcount_by_month {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."GL_CODES_HEADCOUNT_BY_MONTH" ;;

  dimension: date_month {
    type: date_raw
    sql: ${TABLE}."DATE_MONTH" ;;
  }
  dimension: gl_account_no {
    type: number
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
}
