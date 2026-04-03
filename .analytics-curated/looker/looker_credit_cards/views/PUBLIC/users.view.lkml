view: users {
  derived_table: {
    sql:
    select
    *
    ,case when(u.email_address like '%mike.mcclannahan%') then 'mike@equipmentshare.com'
    when(u.email_address like '%jeff.evans@equipmentshare.com%') then 'j.evans@equipmentshare.com'
    when(u.email_address like 'websterbailey@equipmentshare.com') then 'web.bailey@equipmentshare.com'
    else u.email_address end as correct_email_address
    from ES_WAREHOUSE.PUBLIC.users u
    where u.company_id = 1854
    ;;
    }

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

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
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
    sql: ${TABLE}."CORRECT_EMAIL_ADDRESS" ;;
  }

  dimension: employer_user_id {
    type: number
    sql: ${TABLE}."EMPLOYER_USER_ID" ;;
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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: today {
    type: date
    sql: current_timestamp();;
  }

  dimension: submit_spend_receipt {
    type: string
    html: <font color="blue "><u><a href ="https://docs.google.com/forms/d/e/1FAIpQLSfpAR6MGq9OrnnwL9dJz8qZIelo-0gL_W-Guagp9xwoAykUVQ/viewform?usp=pp_url&entry.1164859533={{  _user_attributes['name'] }}&entry.837344666=Credit+Card&entry.1579787528={{today._value}}&entry.130892990={{  _user_attributes['email'] }}"target="_blank">Submit Credit Card Receipt</a></font></u> ;;
    sql: ${user_id};;
  }

  dimension: misisng_receipt_link {
    type: string
    html: <font color="blue "><u><a href ="https://drive.google.com/file/d/1V4y8luZ_oxYBZ-N2CBVyfb6OIJ00mps2/view"target="_blank">Link to Lost Receipt Form</a></font></u>  ;;
    sql: ${user_id};;
  }

  dimension: costcapture_info {
    type: string
    html:<font color="blue "><u><a href = "https://updates.equipmentshare.com/release/QP1fS-costcapture-mobile-app-now-available-to-equipmentshare-employees" target="_blank">Link to CostCapture Info</a></font></u>  ;;
    sql: ${user_id};;
  }

  dimension: user_is_suspended {
    type: yesno
    sql: ${email_address} like '%suspended%' ;;
  }

  dimension: full_name{
    type:  string
    sql: UPPER(CONCAT(TRIM(${first_name}), ' ', TRIM(${last_name}), ' - ', TRIM(${company_directory.employee_id}))) ;;
    suggest_persist_for: "1 minute"
  }

# Changing this to be the same as full_name because it's wrong but I don't want to delete the dimension. -Jack G. 7/26/21
  dimension: full_name_upper_case {
    type: string
    sql: UPPER(CONCAT(TRIM(${first_name}), ' ', TRIM(${last_name}))) ;;
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      user_id,
      username,
      middle_name,
      last_name,
      company_name,
      first_name
    ]
  }
}
