
view: dim_users_bi {
  sql_table_name: BUSINESS_INTELLIGENCE.GOLD.DIM_USERS_BI ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_key {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_KEY" ;;
  }

  dimension: user_source {
    type: string
    sql: ${TABLE}."USER_SOURCE" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_username {
    type: string
    sql: ${TABLE}."USER_USERNAME" ;;
  }

  dimension: user_deleted {
    type: yesno
    sql: ${TABLE}."USER_DELETED" ;;
  }

  dimension: user_employee_key {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_EMPLOYEE_KEY" ;;
  }

  dimension: user_is_employee {
    type: yesno
    sql: ${TABLE}."USER_IS_EMPLOYEE" ;;
  }

  dimension: user_company_key {
    hidden: yes
    type: string
    sql: ${TABLE}."USER_COMPANY_KEY" ;;
  }

  dimension: user_first_name {
    type: string
    sql: ${TABLE}."USER_FIRST_NAME" ;;
  }

  dimension: user_last_name {
    type: string
    sql: ${TABLE}."USER_LAST_NAME" ;;
  }

  dimension: user_full_name {
    type: string
    sql: ${TABLE}."USER_FULL_NAME" ;;
  }

  dimension: user_timezone {
    type: string
    sql: ${TABLE}."USER_TIMEZONE" ;;
  }

  dimension: user_accepted_terms {
    type: yesno
    sql: ${TABLE}."USER_ACCEPTED_TERMS" ;;
  }

  dimension: user_approved_for_purchase_orders {
    type: yesno
    sql: ${TABLE}."USER_APPROVED_FOR_PURCHASE_ORDERS" ;;
  }

  dimension: user_is_salesperson {
    type: yesno
    sql: ${TABLE}."USER_IS_SALESPERSON" ;;
  }

  dimension: user_can_access_camera {
    type: yesno
    sql: ${TABLE}."USER_CAN_ACCESS_CAMERA" ;;
  }

  dimension: user_can_create_asset_financial_records {
    type: yesno
    sql: ${TABLE}."USER_CAN_CREATE_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: user_can_grant_permissions {
    type: yesno
    sql: ${TABLE}."USER_CAN_GRANT_PERMISSIONS" ;;
  }

  dimension: user_can_read_asset_financial_records {
    type: yesno
    sql: ${TABLE}."USER_CAN_READ_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: user_can_rent {
    type: yesno
    sql: ${TABLE}."USER_CAN_RENT" ;;
  }

  dimension: user_sms_opted_out {
    type: yesno
    sql: ${TABLE}."USER_SMS_OPTED_OUT" ;;
  }

  dimension: user_read_only {
    type: yesno
    sql: ${TABLE}."USER_READ_ONLY" ;;
  }

  dimension_group: _created_recordtimestamp {
    type: time
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }

  dimension: user_is_support_user {
    type: yesno
    sql: ${TABLE}."USER_IS_SUPPORT_USER" ;;
  }

  set: detail {
    fields: [
        user_key,
  user_source,
  user_id,
  user_username,
  user_deleted,
  user_employee_key,
  user_is_employee,
  user_company_key,
  user_first_name,
  user_last_name,
  user_full_name,
  user_timezone,
  user_accepted_terms,
  user_approved_for_purchase_orders,
  user_is_salesperson,
  user_can_access_camera,
  user_can_create_asset_financial_records,
  user_can_grant_permissions,
  user_can_read_asset_financial_records,
  user_can_rent,
  user_sms_opted_out,
  user_read_only,
  _created_recordtimestamp_time,
  _updated_recordtimestamp_time,
  user_is_support_user
    ]
  }
}
