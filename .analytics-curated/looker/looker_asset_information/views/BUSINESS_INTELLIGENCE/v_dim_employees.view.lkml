view: v_dim_employees {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_EMPLOYEES" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }
  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
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
  dimension: employee_key {
    type: string
    sql: ${TABLE}."EMPLOYEE_KEY" ;;
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
  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }
  dimension: manager_employee_status {
    type: string
    sql: ${TABLE}."MANAGER_EMPLOYEE_STATUS" ;;
  }
  dimension: manager_first_name {
    type: string
    sql: ${TABLE}."MANAGER_FIRST_NAME" ;;
  }
  dimension: manager_last_name {
    type: string
    sql: ${TABLE}."MANAGER_LAST_NAME" ;;
  }
  dimension: manager_nickname {
    type: string
    sql: ${TABLE}."MANAGER_NICKNAME" ;;
  }
  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
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
  dimension: skip_manager_email {
    type: string
    sql: ${TABLE}."SKIP_MANAGER_EMAIL" ;;
  }
  dimension: skip_manager_employee_status {
    type: string
    sql: ${TABLE}."SKIP_MANAGER_EMPLOYEE_STATUS" ;;
  }
  dimension: skip_manager_first_name {
    type: string
    sql: ${TABLE}."SKIP_MANAGER_FIRST_NAME" ;;
  }
  dimension: skip_manager_last_name {
    type: string
    sql: ${TABLE}."SKIP_MANAGER_LAST_NAME" ;;
  }
  dimension: skip_manager_nickname {
    type: string
    sql: ${TABLE}."SKIP_MANAGER_NICKNAME" ;;
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
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  nickname,
  last_name,
  manager_first_name,
  skip_manager_last_name,
  doc_uname,
  skip_manager_nickname,
  manager_nickname,
  first_name,
  skip_manager_first_name,
  manager_last_name
  ]
  }

}
