view: stg_analytics_payroll__company_directory_vault {
  sql_table_name: "ANALYTICS"."PAYROLL"."STG_ANALYTICS_PAYROLL__COMPANY_DIRECTORY_VAULT" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: account_id {
    type: string
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }
  dimension_group: date_hired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension_group: date_rehired {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REHIRED" ;;
  }
  dimension_group: date_terminated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
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
  dimension: employee_state {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATE" ;;
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
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }
  dimension: is_active_employee {
    type: yesno
    sql: ${TABLE}."IS_ACTIVE_EMPLOYEE" ;;
  }
  dimension: is_on_leave {
    type: yesno
    sql: ${TABLE}."IS_ON_LEAVE" ;;
  }
  dimension: labor_distribution_profile {
    type: string
    sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
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
  dimension: pay_calc {
    type: string
    sql: ${TABLE}."PAY_CALC" ;;
  }
  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }
  dimension_group: position_effective {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
  }
  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }
  dimension: wage_type {
    type: string
    sql: ${TABLE}."WAGE_TYPE" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  direct_manager_name,
  full_name,
  nickname,
  last_name,
  first_name,
  doc_uname
  ]
  }

}
