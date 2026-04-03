include: "/_base/es_warehouse/public/users.view.lkml"

view: +users {
  label: "ES_USERS"

  dimension: user_id {
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accepted_terms {
    hidden: yes
  }
  dimension: approved_for_purchase_orders {
    hidden: yes
  }
  dimension: bad_email_address {
    hidden: yes
  }
  dimension: bad_phone_number {
    hidden: yes
  }
  # dimension: birth_day {
  #   type: number
  #   sql: ${TABLE}."BIRTH_DAY" ;;
  # }
  # dimension: birth_month {
  #   type: number
  #   sql: ${TABLE}."BIRTH_MONTH" ;;
  # }
  # dimension: birth_year {
  #   type: number
  #   sql: ${TABLE}."BIRTH_YEAR" ;;
  # }
  dimension: blockscore_id {
    hidden: yes
  }
  dimension: blockscore_people_id {
    hidden: yes
  }
  dimension: braintree_payment_made {
    hidden: yes
  }
  dimension: branch_id {
    value_format_name: id
  }
  dimension: can_access_camera {
    hidden: yes
  }
  dimension: can_create_asset_financial_records {
    hidden: yes
  }
  dimension: can_grant_permissions {
    hidden: yes
  }
  dimension: can_read_asset_financial_records {
    hidden: yes
  }
  dimension: can_rent {
    hidden: yes
  }
  # dimension: cell_phone_number {
  #   type: string
  #   sql: ${TABLE}."CELL_PHONE_NUMBER" ;;
  # }
  dimension: company_id {
    value_format_name: id
  }
  # dimension: company_name {
  #   type: string
  #   sql: ${TABLE}."COMPANY_NAME" ;;
  # }
  dimension: crm_contact_id {
    hidden: yes
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_created} ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${date_updated} ;;
  }
  # dimension: deleted {
  #   type: yesno
  #   sql: ${TABLE}."DELETED" ;;
  # }
  dimension: description {
    hidden: yes
  }
  dimension: drivers_license {
    hidden: yes
  }
  # dimension: email_address {
  #   type: string
  #   sql: ${TABLE}."EMAIL_ADDRESS" ;;
  # }
  dimension: employee_id {
    type: number
    value_format_name: id
  }
  dimension: employer_user_id {
    hidden: yes
  }
  # dimension: first_name {
  #   type: string
  #   sql: ${TABLE}."FIRST_NAME" ;;
  # }
  dimension: is_salesperson {
    hidden: yes
  }
  dimension: keypad_code {
    hidden: yes
  }
  # dimension: last_name {
  #   type: string
  #   sql: ${TABLE}."LAST_NAME" ;;
  # }
  dimension: last_searched_zip_code {
    hidden: yes
  }
  dimension: link_device_push_id {
    hidden: yes
  }
  dimension: location_id {
    hidden: yes
  }
  # dimension: middle_name {
  #   type: string
  #   sql: ${TABLE}."MIDDLE_NAME" ;;
  # }
  dimension: password_hash {
    hidden: yes
  }
  dimension: phone_number {
    hidden: yes
  }
  dimension: photo_id {
    hidden: yes
  }
  dimension: preferred_landing_page {
    hidden: yes
  }
  dimension: read_only {
    hidden: yes
  }
  dimension: security_level_id {
    hidden: yes
  }
  dimension: sms_opted_out {
    hidden: yes
  }
  dimension: timezone {
    hidden: yes
  }
  dimension: universal_contact_id {
    hidden: yes
  }
  dimension: user_agent_id {
    hidden: yes
  }
  dimension: user_type_id {
    hidden: yes
  }
  # dimension: username {
  #   type: string
  #   sql: ${TABLE}."USERNAME" ;;
  # }
  dimension: verification_status_id {
    hidden: yes
  }
  dimension: xero_salesperson_account_code {
    hidden: yes
  }
  dimension: zip_code {
    hidden: yes
  }


}
