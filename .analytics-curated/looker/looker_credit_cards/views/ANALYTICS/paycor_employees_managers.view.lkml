view: paycor_employees_managers {
  derived_table: {
    sql:
      select *,
             concat(upper(pem.full_employee_name), ' - ', pem.employee_number) as cardholder_full_account
      from analytics.public.paycor_employees_managers pem
      ;;
  }

  dimension: employee_email {
    primary_key: yes
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }

  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: cardholder_full_account {
    type: string
    sql: ${TABLE}."CARDHOLDER_FULL_ACCOUNT" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_employee_name {
    type: string
    sql: UPPER(TRIM(${TABLE}."FULL_EMPLOYEE_NAME")) ;;
  }

  dimension: full_manager_name {
    type: string
    sql: ${TABLE}."FULL_MANAGER_NAME" ;;
  }

  dimension: hire_rehire_date {
    type: string
    sql: ${TABLE}."HIRE_REHIRE_DATE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
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

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
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

  dimension: employee_status {
    type: string
    hidden: yes
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
    suggest_persist_for: "1 minute"
  }

  dimension: employee_status_flag {
    type: string
    sql: case when ${employee_status} in ('Not in Payroll', 'Never Started', 'Inactive', 'Terminated') then 'Terminated'
              else 'Active' end;;
    suggest_persist_for: "1 minute"
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      last_name,
      first_name,
      manager_last_name,
      manager_first_name,
      full_employee_name,
      full_manager_name
    ]
  }
}
