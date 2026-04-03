view: users {
  sql_table_name: "PUBLIC"."USERS"
    ;;
  drill_fields: [employer_user_id]

  dimension: employer_user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYER_USER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: accepted_terms {
    type: yesno
    sql: ${TABLE}."ACCEPTED_TERMS" ;;
  }

  dimension: approved_for_purchase_orders {
    type: yesno
    sql: ${TABLE}."APPROVED_FOR_PURCHASE_ORDERS" ;;
  }

  dimension: bad_email_address {
    type: yesno
    sql: ${TABLE}."BAD_EMAIL_ADDRESS" ;;
  }

  dimension: bad_phone_number {
    type: yesno
    sql: ${TABLE}."BAD_PHONE_NUMBER" ;;
  }

  dimension: birth_day {
    type: number
    sql: ${TABLE}."BIRTH_DAY" ;;
  }

  dimension: birth_month {
    type: number
    sql: ${TABLE}."BIRTH_MONTH" ;;
  }

  dimension: birth_year {
    type: number
    sql: ${TABLE}."BIRTH_YEAR" ;;
  }

  dimension: blockscore_id {
    type: string
    sql: ${TABLE}."BLOCKSCORE_ID" ;;
  }

  dimension: blockscore_people_id {
    type: number
    sql: ${TABLE}."BLOCKSCORE_PEOPLE_ID" ;;
  }

  dimension: braintree_payment_made {
    type: string
    sql: ${TABLE}."BRAINTREE_PAYMENT_MADE" ;;
  }

  dimension: can_create_asset_financial_records {
    type: yesno
    sql: ${TABLE}."CAN_CREATE_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: can_read_asset_financial_records {
    type: yesno
    sql: ${TABLE}."CAN_READ_ASSET_FINANCIAL_RECORDS" ;;
  }

  dimension: cell_phone_number {
    type: string
    sql: ${TABLE}."CELL_PHONE_NUMBER" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: drivers_license {
    type: string
    sql: ${TABLE}."DRIVERS_LICENSE" ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: is_salesperson {
    type: yesno
    sql: ${TABLE}."IS_SALESPERSON" ;;
  }

  dimension: keypad_code {
    type: string
    sql: ${TABLE}."KEYPAD_CODE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: last_searched_zip_code {
    type: number
    sql: ${TABLE}."LAST_SEARCHED_ZIP_CODE" ;;
  }

  dimension: link_device_push_id {
    type: string
    sql: ${TABLE}."LINK_DEVICE_PUSH_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: middle_name {
    type: string
    sql: ${TABLE}."MIDDLE_NAME" ;;
  }

  dimension: password_hash {
    type: string
    sql: ${TABLE}."PASSWORD_HASH" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: photo_id {
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  dimension: preferred_landing_page {
    type: string
    sql: ${TABLE}."PREFERRED_LANDING_PAGE" ;;
  }

  dimension: read_only {
    type: yesno
    sql: ${TABLE}."READ_ONLY" ;;
  }

  dimension: security_level_id {
    type: number
    sql: ${TABLE}."SECURITY_LEVEL_ID" ;;
  }

  dimension: sms_opted_out {
    type: yesno
    sql: ${TABLE}."SMS_OPTED_OUT" ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_type_id {
    type: number
    sql: ${TABLE}."USER_TYPE_ID" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: verification_status_id {
    type: number
    sql: ${TABLE}."VERIFICATION_STATUS_ID" ;;
  }

  dimension: xero_salesperson_account_code {
    type: string
    sql: ${TABLE}."XERO_SALESPERSON_ACCOUNT_CODE" ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: mechanic {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      employer_user_id,
      first_name,
      company_name,
      last_name,
      username,
      middle_name,
      users.first_name,
      users.company_name,
      users.last_name,
      users.username,
      users.employer_user_id,
      users.middle_name,
      users.count
    ]
  }
}
