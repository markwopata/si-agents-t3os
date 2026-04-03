view: paycor_employees_managers_full_hierarchy {
  sql_table_name: "ANALYTICS"."PUBLIC"."PAYCOR_EMPLOYEES_MANAGERS_FULL_HIERARCHY"
    ;;

  dimension: dept_name {
    type: string
    sql: ${TABLE}."DEPT_NAME" ;;
  }

  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_number {
    type: string
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
    primary_key: yes
  }

  measure: total_employee_number {
    type: sum
    sql: ${employee_number} ;;
  }

  measure: average_employee_number {
    type: average
    sql: ${employee_number} ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: ${TABLE}."FULL_EMPLOYEE_NAME" ;;
  }

  dimension: full_manager_name {
    type: string
    sql: ${TABLE}."FULL_MANAGER_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: loc_name {
    type: string
    sql: ${TABLE}."LOC_NAME" ;;
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
    type: number
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

  dimension: report_type {
    type: string
    sql: ${TABLE}."REPORT_TYPE" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      dept_name,
      manager_first_name,
      full_manager_name,
      last_name,
      first_name,
      manager_last_name,
      full_employee_name,
      loc_name
    ]
  }
}
