view: docebo_user_data {
  sql_table_name: "DOCEBO"."DOCEBO_USER_DATA" ;;

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: are_you_a_manager {
    type: string
    sql: ${TABLE}."ARE_YOU_A_MANAGER" ;;
  }
  dimension: company_tenure {
    type: number
    sql: ${TABLE}."COMPANY_TENURE" ;;
  }
  dimension: department_code {
    type: string
    sql: ${TABLE}."DEPARTMENT_CODE" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }
  dimension: disc {
    type: string
    sql: ${TABLE}."DISC" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: division {
    type: string
    sql: ${TABLE}."DIVISION" ;;
  }
  dimension: employee_email {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL" ;;
  }
  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }
  dimension: employee_password {
    type: number
    sql: ${TABLE}."EMPLOYEE_PASSWORD" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: hire_date {
    type: string
    sql: ${TABLE}."HIRE_DATE" ;;
  }
  dimension: hourly_salary {
    type: string
    sql: ${TABLE}."HOURLY_SALARY" ;;
  }
  dimension: is_manager {
    type: string
    sql: ${TABLE}."IS_MANAGER" ;;
  }
  dimension_group: job_last_changed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."JOB_LAST_CHANGED_DATE" ;;
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
    type: string
    sql: ${TABLE}."MANAGER_EMPLOYEE_NUMBER" ;;
  }
  dimension: on_leave {
    type: string
    sql: ${TABLE}."ON_LEAVE" ;;
  }
  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: rehire_date {
    type: string
    sql: ${TABLE}."REHIRE_DATE" ;;
  }
  dimension: rehired {
    type: yesno
    sql: ${TABLE}."REHIRED" ;;
  }
  dimension: remote {
    type: string
    sql: ${TABLE}."REMOTE" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }
  dimension: tenure_1095_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_1095_DAYS_OR_MORE" ;;
  }
  dimension: tenure_14_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_14_DAYS_OR_MORE" ;;
  }
  dimension: tenure_180_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_180_DAYS_OR_MORE" ;;
  }
  dimension: tenure_30_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_30_DAYS_OR_MORE" ;;
  }
  dimension: tenure_60_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_60_DAYS_OR_MORE" ;;
  }
  dimension: tenure_7_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_7_DAYS_OR_MORE" ;;
  }
  dimension: tenure_90_days_or_more {
    type: string
    sql: ${TABLE}."TENURE_90_DAYS_OR_MORE" ;;
  }
  dimension: termination_date {
    type: string
    sql: ${TABLE}."TERMINATION_DATE" ;;
  }
  dimension: username {
    type: number
    sql: ${TABLE}."USERNAME" ;;
  }
  dimension: vehicle {
    type: string
    sql: ${TABLE}."VEHICLE" ;;
  }
  measure: count {
    type: count
    drill_fields: [loc_name, username, department_name, first_name, last_name]
  }
}
