view: ukg_employees {
  sql_table_name: "ANALYTICS"."DOCEBO"."UKG_EMPLOYEES"
    ;;

  dimension: department_code {
    type: string
    sql: ${TABLE}."DEPARTMENT_CODE" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: employee {
    type: string
    sql: ${TABLE}."EMPLOYEE" ;;
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_number {
    type: string
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: employee_password {
    type: string
    sql: ${TABLE}."EMPLOYEE_PASSWORD" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_username {
    type: string
    sql: ${TABLE}."EMPLOYEE_USERNAME" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension_group: hire {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."HIRE_DATE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: loc_name {
    type: string
    sql: ${TABLE}."LOC_NAME" ;;
  }

  dimension: is_manager {
    type: string
    sql: ${TABLE}."IS_MANAGER" ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: manager_employee_number {
    type: string
    sql: ${TABLE}."MANAGER_EMPLOYEE_NUMBER" ;;
  }

  dimension: manager_first_name {
    type: string
    sql: ${TABLE}."MANAGER_FIRST_NAME" ;;
  }

  dimension: manager_last_name {
    type: string
    sql: ${TABLE}."MANAGER_LAST_NAME" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: active {
    type: string
    sql: ${TABLE}."ACTIVE";;
  }

  dimension: on_leave {
    type: string
    sql: ${TABLE}."ON_LEAVE";;
  }

  dimension: manager_username {
    type: string
    sql: ${TABLE}."MANAGER_USERNAME" ;;
  }

  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }

  dimension: rehired {
    type: string
    sql: ${TABLE}."REHIRED" ;;
  }

  dimension_group: rehire {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."REHIRE_DATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      department_name,
      manager_username,
      manager_last_name,
      first_name,
      manager_first_name,
      loc_name,
      employee_username,
      last_name
    ]
  }
}
