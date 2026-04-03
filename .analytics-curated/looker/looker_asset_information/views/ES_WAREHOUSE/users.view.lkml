view: users {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."USERS"
    ;;
  drill_fields: [user_id]

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."USER_ID" ;;
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

  dimension: employer_user_id {
    type: number
    sql: ${TABLE}."EMPLOYER_USER_ID" ;;
  }

  dimension: employee_id {
    type: string # it shouldn't be a string, but it isn't.
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

  dimension: security_level_id {
    type: number
    sql: ${TABLE}."SECURITY_LEVEL_ID" ;;
  }

  dimension: timezone {
    type: string
    sql: ${TABLE}."TIMEZONE" ;;
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

  measure: number_of_users {
    type: count
    drill_fields: [detail*]
  }

  dimension: Full_Name{
    type:  string
    sql: CASE WHEN ${first_name} is null THEN 'No Salesperson Assigned' else concat(trim(${first_name}),' ',trim(${last_name})) END ;;
  }

  dimension: name {
    sql: concat(trim(${first_name}),' ',trim(${last_name})) ;;
  }

  measure: name_list {
    type: list
    list_field: name
  }

  dimension: Full_Name_with_ID {
    type: string
    sql: concat(${Full_Name},' - ',${user_id}) ;;
    suggest_persist_for: "5 hours"
  }

  dimension: sales_rep_id_link_to_salesperson_dashboard {
    type: string
    sql: ${Full_Name_with_ID} ;;
    link: {
      label: "View Salesperson Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/5?Sales%20Rep={{ value | url_encode }}"
    }
    description: "This links out to the Salesperson dashboard"
  }

  dimension: Full_Name_with_ID_national {
    type: string
    sql: concat(${Full_Name},' - ',${user_id}) ;;
  }

  dimension: requested_by {
    type:  string
    sql: concat(trim(${first_name}),' ',trim(${last_name})) ;;
  }

  dimension: sales_rep {
    label: "TAM"
    type:  string
    sql: CASE
          WHEN ${first_name} IS NULL THEN 'No Salesperson Assigned'
          ELSE TRIM(CONCAT(${first_name}, ' ', ${last_name}))
        END ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      user_id,
      username,
      last_name,
      middle_name,
      first_name,
      company_name,
      orders.count
    ]
  }
}
