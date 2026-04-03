view: payroll_details {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."PAYROLL_DETAILS" ;;

  dimension: _cost_centers_full_path {
    type: string
    sql: ${TABLE}."_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: _cost_centers_name_department {
    type: string
    sql: ${TABLE}."_COST_CENTERS_NAME_(DEPARTMENT)" ;;
  }
  dimension: _cost_centers_name_division {
    type: string
    sql: ${TABLE}."_COST_CENTERS_NAME_(DIVISION)" ;;
  }
  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: cost_centersdivision {
    type: string
    sql: ${TABLE}."COST_CENTERS(DIVISION)" ;;
  }
  dimension: credit {
    type: number
    sql: ${TABLE}."CREDIT" ;;
  }
  dimension: debit {
    type: number
    sql: ${TABLE}."DEBIT" ;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: default_cost_centers_intaact {
    type: number
    sql: ${TABLE}."DEFAULT_COST_CENTERS_INTAACT" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: entry_type {
    type: string
    sql: ${TABLE}."ENTRY_TYPE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: gl_account_no {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO" ;;
  }
  dimension: gl_account_no_description {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NO_DESCRIPTION" ;;
  }
  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: intaact {
    type: string
    sql: ${TABLE}."INTAACT" ;;
  }
  dimension: jobs_hr1 {
    type: string
    sql: ${TABLE}."JOBS_(HR)(1)" ;;
  }
  dimension: labor_distribution_profile {
    type: string
    sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: pay_day {
    type: string
    sql: ${TABLE}."PAY_DATE" ;;
  }
  dimension: pay_period_end {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_END" ;;
    hidden: yes
  }
  dimension: pay_period_start {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_START" ;;
    hidden: yes
  }
  dimension: payroll_name {
    type: string
    sql: ${TABLE}."PAYROLL_NAME" ;;
  }
  dimension: payroll_status {
    type: string
    sql: ${TABLE}."PAYROLL_STATUS" ;;
  }
  dimension: payroll_system_id {
    type: number
    sql: ${TABLE}."PAYROLL_SYSTEM_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [first_name, last_name, payroll_name]
  }
}
