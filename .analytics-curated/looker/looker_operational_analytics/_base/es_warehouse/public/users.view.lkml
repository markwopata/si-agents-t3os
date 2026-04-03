view: users {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."USERS" ;;

  dimension_group: es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: accepted_terms {
    type: yesno
    sql: ${TABLE}."ACCEPTED_TERMS" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: approved_for_purchase_orders {
    type: yesno
    sql: ${TABLE}."APPROVED_FOR_PURCHASE_ORDERS" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: blockscore_id {
    type: string
    sql: ${TABLE}."BLOCKSCORE_ID" ;;
  }

  dimension: employer_user_id {
    type: number
    sql: ${TABLE}."EMPLOYER_USER_ID" ;;
  }

  dimension: xero_salesperson_account_code {
    type: string
    sql: ${TABLE}."XERO_SALESPERSON_ACCOUNT_CODE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: middle_name {
    type: string
    sql: ${TABLE}."MIDDLE_NAME" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: drivers_license {
    type: string
    sql: ${TABLE}."DRIVERS_LICENSE" ;;
  }

  dimension: is_salesperson {
    type: yesno
    sql: ${TABLE}."IS_SALESPERSON" ;;
  }

  dimension: birth_day {
    type: number
    sql: ${TABLE}."BIRTH_DAY" ;;
  }

  dimension: birth_year {
    type: number
    sql: ${TABLE}."BIRTH_YEAR" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: zip_code {
    type: string
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  dimension: braintree_payment_made {
    type: yesno
    sql: ${TABLE}."BRAINTREE_PAYMENT_MADE" ;;
  }

  dimension: last_searched_zip_code {
    type: string
    sql: ${TABLE}."LAST_SEARCHED_ZIP_CODE" ;;
  }

  dimension: bad_email_address {
    type: yesno
    sql: ${TABLE}."BAD_EMAIL_ADDRESS" ;;
  }

  dimension: security_level_id {
    type: number
    sql: ${TABLE}."SECURITY_LEVEL_ID" ;;
  }

  dimension: password_hash {
    type: string
    sql: ${TABLE}."PASSWORD_HASH" ;;
  }

  dimension: keypad_code {
    type: string
    sql: ${TABLE}."KEYPAD_CODE" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: birth_month {
    type: number
    sql: ${TABLE}."BIRTH_MONTH" ;;
  }

  dimension: bad_phone_number {
    type: yesno
    sql: ${TABLE}."BAD_PHONE_NUMBER" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: verification_status_id {
    type: number
    sql: ${TABLE}."VERIFICATION_STATUS_ID" ;;
  }

  dimension: blockscore_people_id {
    type: string
    sql: ${TABLE}."BLOCKSCORE_PEOPLE_ID" ;;
  }

  dimension: photo_id {
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: link_device_push_id {
    type: string
    sql: ${TABLE}."LINK_DEVICE_PUSH_ID" ;;
  }

  dimension: user_type_id {
    type: number
    sql: ${TABLE}."USER_TYPE_ID" ;;
  }

  dimension: read_only {
    type: yesno
    sql: ${TABLE}."READ_ONLY" ;;
  }

  dimension: preferred_landing_page {
    type: string
    sql: ${TABLE}."PREFERRED_LANDING_PAGE" ;;
  }

  dimension: cell_phone_number {
    type: string
    sql: ${TABLE}."CELL_PHONE_NUMBER" ;;
  }

  dimension: sms_opted_out {
    type: yesno
    sql: ${TABLE}."SMS_OPTED_OUT" ;;
  }

  dimension: can_create_asset_financial_records {
    type: yesno
    sql: ${TABLE}."CAN_CREATE_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: can_read_asset_financial_records {
    type: yesno
    sql: ${TABLE}."CAN_READ_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: can_access_camera {
    type: yesno
    sql: ${TABLE}."CAN_ACCESS_CAMERA" ;;
  }

  dimension: can_rent {
    type: yesno
    sql: ${TABLE}."CAN_RENT" ;;
  }

  dimension: crm_contact_id {
    type: string
    sql: ${TABLE}."CRM_CONTACT_ID" ;;
  }

  dimension: user_agent_id {
    type: number
    sql: ${TABLE}."USER_AGENT_ID" ;;
  }

  dimension: can_grant_permissions {
    type: yesno
    sql: ${TABLE}."CAN_GRANT_PERMISSIONS" ;;
  }

  dimension: universal_contact_id {
    type: string
    sql: ${TABLE}."UNIVERSAL_CONTACT_ID" ;;
  }

  dimension: can_access_accident_reports {
    type: yesno
    sql: ${TABLE}."CAN_ACCESS_ACCIDENT_REPORTS" ;;
  }

  dimension: user_shift_type_id {
    type: number
    sql: ${TABLE}."USER_SHIFT_TYPE_ID" ;;
  }

  dimension: company_division_id {
    type: number
    sql: ${TABLE}."COMPANY_DIVISION_ID" ;;
  }

  dimension: craft_type_id {
    type: number
    sql: ${TABLE}."CRAFT_TYPE_ID" ;;
  }

  dimension: supervisor_id {
    type: number
    sql: ${TABLE}."SUPERVISOR_ID" ;;
  }
}
