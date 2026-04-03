view: company_directory {
  sql_table_name: "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY"
    ;;

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

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: employee_full_name {
    type: string
    sql: case when position(' ',coalesce(${nickname},${first_name})) = 0 then concat(coalesce(${nickname},${first_name}), ' ', ${last_name})
    else concat(coalesce(${nickname},concat(${first_name}, ' ',${last_name}))) end ;;
  }

  measure: count_distinct {
    type: count_distinct
    sql: ${work_email} ;;
    drill_fields: [employee_full_name,employee_id,employee_title]
  }

  measure: count {
    type: count
    drill_fields: [last_name, nickname, first_name, direct_manager_name]
  }
}
