view: company_directory {
  sql_table_name: "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" ;;

  dimension: account_id {
    type: string
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }
  dimension: date_hired {
    type: string
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension: date_rehired {
    type: string
    sql: ${TABLE}."DATE_REHIRED" ;;
  }
  dimension: date_terminated {
    type: string
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: direct_manager_employee_id {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: doc_uname {
    type: string
    sql: ${TABLE}."DOC_UNAME" ;;
  }
  dimension: ee_state {
    type: string
    sql: ${TABLE}."EE_STATE" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }
  dimension: labor_distribution_profile {
    type: string
    sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: last_updated_date {
    type: string
    sql: ${TABLE}."LAST_UPDATED_DATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }
  dimension: on_leave {
    type: number
    sql: ${TABLE}."ON_LEAVE" ;;
  }
  dimension: pay_calc {
    type: string
    sql: ${TABLE}."PAY_CALC" ;;
  }
  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }
  dimension: position_effective_date {
    type: string
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
  }
  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }
  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }
  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }
  dimension: worker_type {
    type: string
    sql: ${TABLE}."WORKER_TYPE" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, direct_manager_name, first_name, doc_uname, nickname]
  }
}
