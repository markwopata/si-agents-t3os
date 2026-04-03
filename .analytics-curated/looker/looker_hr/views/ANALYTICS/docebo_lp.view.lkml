view: docebo_lp {
  sql_table_name: "PUBLIC"."DOCEBO_LP"
    ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
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
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
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
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: are_you_a_manager_ {
    type: string
    sql: ${TABLE}."ARE_YOU_A_MANAGER_" ;;
  }

  dimension_group: completion {
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
    sql: ${TABLE}."COMPLETION_DATE" ;;
  }

  dimension: completion_percentage {
    type: number
    sql: ${TABLE}."COMPLETION_PERCENTAGE" ;;
  }

  dimension: deactivated {
    type: string
    sql: ${TABLE}."DEACTIVATED" ;;
  }

  dimension: department_code {
    type: number
    sql: ${TABLE}."DEPARTMENT_CODE" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: email_validation_status {
    type: string
    sql: ${TABLE}."EMAIL_VALIDATION_STATUS" ;;
  }

  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension_group: enrollment {
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
    sql: ${TABLE}."ENROLLMENT_DATE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
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

  dimension: hourly_salary {
    type: string
    sql: ${TABLE}."HOURLY_SALARY" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: learning_plan_enrollment_status {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_ENROLLMENT_STATUS" ;;
  }

  dimension: learning_plan_name {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_NAME" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
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

  dimension: market_address {
    type: string
    sql: ${TABLE}."MARKET_ADDRESS" ;;
  }

  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }

  dimension_group: user_creation {
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
    sql: ${TABLE}."USER_CREATION_DATE" ;;
  }

  dimension_group: user_last_access {
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
    sql: ${TABLE}."USER_LAST_ACCESS_DATE" ;;
  }

  dimension: user_unique_id {
    type: number
    sql: ${TABLE}."USER_UNIQUE_ID" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
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
      full_name,
      learning_plan_name,
      username,
      department_name,
      last_name,
      first_name,
      location_name
    ]
  }
}
