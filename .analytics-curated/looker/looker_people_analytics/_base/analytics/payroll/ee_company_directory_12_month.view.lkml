view: ee_company_directory_12_month {
  sql_table_name: "ANALYTICS"."PAYROLL"."EE_COMPANY_DIRECTORY_12_MONTH" ;;

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: date_hired {
    type: date_raw
    sql: ${TABLE}."DATE_HIRED" ;;
  }
  dimension: date_rehired {
    type: date_raw
    sql: ${TABLE}."DATE_REHIRED" ;;
  }
  dimension: date_terminated {
    type: date_raw
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }
  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }
  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: disc_code {
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
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
  dimension: headcount {
    type: number
    sql: ${TABLE}."HEADCOUNT" ;;
  }
  dimension: hires {
    type: number
    sql: ${TABLE}."HIRES" ;;
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
  dimension: position_effective {
    type: date_raw
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
  }
  dimension: rehires {
    type: number
    sql: ${TABLE}."REHIRES" ;;
  }
  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }
  dimension: terminations {
    type: number
    sql: ${TABLE}."TERMINATIONS" ;;
  }
  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }
  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }
  measure: count {
    type: count
    drill_fields: [nickname, first_name, direct_manager_name, last_name, doc_uname]
  }
}
