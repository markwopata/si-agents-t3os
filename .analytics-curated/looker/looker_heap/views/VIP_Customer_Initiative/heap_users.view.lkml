
view: heap_users {
  derived_table: {
    sql: SELECT
      es_user_id
      , heap_user_id
      , user_created
      , company_created
      , company_id
      , user_name
      , email
      , USER_TIMEZONE
      , company_name
      , user_created_cohort
      , company_created_cohort
      , has_keypad_code
      , HAS_PREFERRED_LANDING_PAGE
      , PREFERRED_LANDING_PAGE
      , tenure_days
      , COUNT_HEAP_IDS
      , CREATED_TENURE_DAYS
      , COMPANY_CREATED_TENURE_DAYS
      , CAN_RENT
      , CAN_ACCESS_CAMERA
      , CAN_CREATE_ASSET_FINANCIAL_RECORDS
      , HAS_EMPLOYEE_ID
      , FIRST_NAME
      , LAST_NAME
      , BRANCH_ID

      FROM T3_ANALYTICS.VW_FILTERED_USERS_DATA
      WHERE HEAP_USER_RANK = 1 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}."ES_USER_ID" ;;
  }

  dimension: heap_user_id {
    type: string
    sql: ${TABLE}."HEAP_USER_ID" ;;
  }

  dimension_group: user_created {
    type: time
    sql: ${TABLE}."USER_CREATED" ;;
  }

  dimension_group: company_created {
    type: time
    sql: ${TABLE}."COMPANY_CREATED" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: user_timezone {
    type: string
    sql: ${TABLE}."USER_TIMEZONE" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: user_created_cohort {
    type: string
    sql: ${TABLE}."USER_CREATED_COHORT" ;;
  }

  dimension: company_created_cohort {
    type: string
    sql: ${TABLE}."COMPANY_CREATED_COHORT" ;;
  }

  dimension: has_keypad_code {
    type: yesno
    sql: ${TABLE}."HAS_KEYPAD_CODE" ;;
  }

  dimension: has_preferred_landing_page {
    type: yesno
    sql: ${TABLE}."HAS_PREFERRED_LANDING_PAGE" ;;
  }

  dimension: preferred_landing_page {
    type: string
    sql: ${TABLE}."PREFERRED_LANDING_PAGE" ;;
  }

  dimension: tenure_days {
    type: number
    sql: ${TABLE}."TENURE_DAYS" ;;
  }

  dimension: count_heap_ids {
    type: number
    sql: ${TABLE}."COUNT_HEAP_IDS" ;;
  }

  dimension: created_tenure_days {
    type: number
    sql: ${TABLE}."CREATED_TENURE_DAYS" ;;
  }

  dimension: company_created_tenure_days {
    type: number
    sql: ${TABLE}."COMPANY_CREATED_TENURE_DAYS" ;;
  }

  dimension: can_rent {
    type: yesno
    sql: ${TABLE}."CAN_RENT" ;;
  }

  dimension: can_access_camera {
    type: yesno
    sql: ${TABLE}."CAN_ACCESS_CAMERA" ;;
  }

  dimension: can_create_asset_financial_records {
    type: yesno
    sql: ${TABLE}."CAN_CREATE_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: has_employee_id {
    type: yesno
    sql: ${TABLE}."HAS_EMPLOYEE_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  set: detail {
    fields: [
      es_user_id,
      heap_user_id,
      user_created_time,
      company_created_time,
      company_id,
      user_name,
      email,
      user_timezone,
      company_name,
      user_created_cohort,
      company_created_cohort,
      has_keypad_code,
      has_preferred_landing_page,
      preferred_landing_page,
      tenure_days,
      count_heap_ids,
      created_tenure_days,
      company_created_tenure_days,
      can_rent,
      can_access_camera,
      can_create_asset_financial_records,
      has_employee_id,
      first_name,
      last_name,
      branch_id
    ]
  }
}
