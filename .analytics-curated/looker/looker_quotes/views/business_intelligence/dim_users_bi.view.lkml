view: dim_users_bi {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_USERS_BI" ;;

  dimension: user_approved_for_purchase_orders {
    type: yesno
    sql: ${TABLE}."USER_APPROVED_FOR_PURCHASE_ORDERS" ;;
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

  dimension: user_company_key {
    type: string
    hidden:  yes
    sql: ${TABLE}."USER_COMPANY_KEY" ;;
  }

  dimension: user_deleted {
    type: yesno
    sql: ${TABLE}."USER_DELETED" ;;
  }

  dimension: user_employee_key {
    type: string
    hidden:  yes
    sql: ${TABLE}."USER_EMPLOYEE_KEY" ;;
  }

  dimension: user_first_name {
    type: string
    sql: ${TABLE}."USER_FIRST_NAME" ;;
  }

  dimension: user_full_name {
    type: string
    sql: ${TABLE}."USER_FULL_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_is_employee {
    type: yesno
    sql: ${TABLE}."USER_IS_EMPLOYEE" ;;
  }

  dimension: user_is_salesperson {
    type: yesno
    sql: ${TABLE}."USER_IS_SALESPERSON" ;;
  }

  dimension: user_key {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${TABLE}."USER_KEY" ;;
  }

  dimension: user_last_name {
    type: string
    sql: ${TABLE}."USER_LAST_NAME" ;;
  }

  dimension: user_read_only {
    type: string
    sql: ${TABLE}."USER_READ_ONLY" ;;
  }

  dimension: user_sms_opted_out {
    type: yesno
    sql: ${TABLE}."USER_SMS_OPTED_OUT" ;;
  }

  dimension: user_source {
    type: string
    sql: ${TABLE}."USER_SOURCE" ;;
  }

  dimension: user_timezone {
    type: string
    sql: ${TABLE}."USER_TIMEZONE" ;;
  }

  dimension: user_username {
    type: string
    sql: ${TABLE}."USER_USERNAME" ;;
  }

}
