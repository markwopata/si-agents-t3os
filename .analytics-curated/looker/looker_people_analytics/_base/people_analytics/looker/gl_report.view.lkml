view: gl_report {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."GL_REPORT" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: corrected_cost_center {
    type: string
    sql: ${TABLE}."CORRECTED_COST_CENTER" ;;
  }
  dimension: cost_centers_full_path {
    type: string
    sql: ${TABLE}."COST_CENTERS_FULL_PATH" ;;
  }
  dimension: credit {
    type: string
    sql: ${TABLE}."CREDIT" ;;
  }
  dimension: debit {
    type: string
    sql: ${TABLE}."DEBIT" ;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
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
    type: string
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE" ;;
  }
  dimension: job_title {
    type: string
    sql: ${TABLE}."JOB_TITLE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: pay_date {
    type: date_raw
    sql: ${TABLE}."PAY_DATE" ;;
  }
  dimension: pay_period_end {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_END" ;;
  }
  dimension: pay_period_start {
    type: date_raw
    sql: ${TABLE}."PAY_PERIOD_START" ;;
  }
  dimension: payroll_name {
    type: string
    sql: ${TABLE}."PAYROLL_NAME" ;;
  }
  dimension: payroll_status {
    type: string
    sql: ${TABLE}."PAYROLL_STATUS" ;;
  }
}
