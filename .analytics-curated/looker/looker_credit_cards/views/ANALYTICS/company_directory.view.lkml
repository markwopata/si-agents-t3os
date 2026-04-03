view: company_directory {
  sql_table_name: "PAYROLL"."COMPANY_DIRECTORY"
    ;;

  dimension_group: _es_update_timestamp {
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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
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
    type: string
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

  dimension: name_with_employee_id {
    label: "Full Name with EID"
    type: string
    sql: upper(concat(${TABLE}."FIRST_NAME",' ',${TABLE}."LAST_NAME",' - ',${TABLE}."EMPLOYEE_ID")) ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: employee_status_flag {
    type: string
    sql: case when ${employee_status} in ('Not in Payroll', 'Never Started', 'Inactive', 'Terminated') then 'Terminated'
      else 'Active' end;;
    suggest_persist_for: "1 minute"
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

   dimension: cost_center_lvl_1 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',1)) ;;
  }

  dimension: cost_center_lvl_2 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',2)) ;;
  }

  dimension: cost_center_lvl_3 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',3)) ;;
  }

  dimension: cost_center_lvl_4 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',4)) ;;
  }

  dimension: cost_center_lvl_5 {
    type: string
    sql: trim(split_part(${default_cost_centers_full_path},'/',5)) ;;
  }

  dimension: last_cost_center {
    type: string
    sql: coalesce(coalesce(coalesce(coalesce(${cost_center_lvl_5}, ${cost_center_lvl_4}), ${cost_center_lvl_3}), ${cost_center_lvl_2}), ${cost_center_lvl_1});;
  }

  measure: count {
    type: count
    drill_fields: [direct_manager_name, first_name, last_name, nickname]
  }
}
