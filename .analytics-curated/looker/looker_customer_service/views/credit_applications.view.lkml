view: credit_applications {
  sql_table_name: "ES_WAREHOUSE"."CREDIT_APPLICATION"."CREDIT_APPLICATIONS" ;;
  drill_fields: [credit_application_id]

  dimension: credit_application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_APPLICATION_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: account_payable_contact_first_name {
    type: string
    sql: ${TABLE}."ACCOUNT_PAYABLE_CONTACT_FIRST_NAME" ;;
  }
  dimension: account_payable_contact_last_name {
    type: string
    sql: ${TABLE}."ACCOUNT_PAYABLE_CONTACT_LAST_NAME" ;;
  }
  dimension: billing_address_city {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS_CITY" ;;
  }
  dimension: billing_address_state_id {
    type: number
    sql: ${TABLE}."BILLING_ADDRESS_STATE_ID" ;;
  }
  dimension: billing_address_street_1 {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS_STREET_1" ;;
  }
  dimension: billing_address_zip_code {
    type: string
    sql: ${TABLE}."BILLING_ADDRESS_ZIP_CODE" ;;
  }
  dimension: billing_email {
    type: string
    sql: ${TABLE}."BILLING_EMAIL" ;;
  }
  dimension: billing_phone {
    type: string
    sql: ${TABLE}."BILLING_PHONE" ;;
  }
  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: business_legal_name {
    type: string
    sql: ${TABLE}."BUSINESS_LEGAL_NAME" ;;
  }
  dimension: business_nature {
    type: string
    sql: ${TABLE}."BUSINESS_NATURE" ;;
  }
  dimension: company_address_city {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS_CITY" ;;
  }
  dimension: company_address_latitude {
    type: number
    sql: ${TABLE}."COMPANY_ADDRESS_LATITUDE" ;;
  }
  dimension: company_address_longitude {
    type: number
    sql: ${TABLE}."COMPANY_ADDRESS_LONGITUDE" ;;
  }
  dimension: company_address_state_id {
    type: number
    sql: ${TABLE}."COMPANY_ADDRESS_STATE_ID" ;;
  }
  dimension: company_address_street_1 {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS_STREET_1" ;;
  }
  dimension: company_address_zip_code {
    type: string
    sql: ${TABLE}."COMPANY_ADDRESS_ZIP_CODE" ;;
  }
  dimension: company_application_id {
    type: number
    sql: ${TABLE}."COMPANY_APPLICATION_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: contact_email {
    type: string
    sql: ${TABLE}."CONTACT_EMAIL" ;;
  }
  dimension: contact_name {
    type: string
    sql: ${TABLE}."CONTACT_NAME" ;;
  }
  dimension: contact_phone {
    type: string
    sql: ${TABLE}."CONTACT_PHONE" ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension: credit_application_external_ref {
    type: string
    sql: ${TABLE}."CREDIT_APPLICATION_EXTERNAL_REF" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: disable_monthly_statements {
    type: yesno
    sql: ${TABLE}."DISABLE_MONTHLY_STATEMENTS" ;;
  }
  dimension: doing_business_as {
    type: string
    sql: ${TABLE}."DOING_BUSINESS_AS" ;;
  }
  dimension: federal_tax_id {
    type: string
    sql: ${TABLE}."FEDERAL_TAX_ID" ;;
  }
  dimension: in_bankruptcy {
    type: yesno
    sql: ${TABLE}."IN_BANKRUPTCY" ;;
  }
  dimension: insurance_company {
    type: string
    sql: ${TABLE}."INSURANCE_COMPANY" ;;
  }
  dimension: insurance_contact_first_name {
    type: string
    sql: ${TABLE}."INSURANCE_CONTACT_FIRST_NAME" ;;
  }
  dimension: insurance_contact_last_name {
    type: string
    sql: ${TABLE}."INSURANCE_CONTACT_LAST_NAME" ;;
  }
  dimension: insurance_email {
    type: string
    sql: ${TABLE}."INSURANCE_EMAIL" ;;
  }
  dimension: insurance_phone {
    type: string
    sql: ${TABLE}."INSURANCE_PHONE" ;;
  }
  dimension: is_paperless_billing {
    type: string
    sql: ${TABLE}."IS_PAPERLESS_BILLING" ;;
  }
  dimension: is_po_required {
    type: yesno
    sql: ${TABLE}."IS_PO_REQUIRED" ;;
  }
  dimension: is_sales_exempt {
    type: yesno
    sql: ${TABLE}."IS_SALES_EXEMPT" ;;
  }
  dimension: org_state {
    type: number
    sql: ${TABLE}."ORG_STATE" ;;
  }
  dimension: own_insurance {
    type: yesno
    sql: ${TABLE}."OWN_INSURANCE" ;;
  }
  dimension: payment_method_id {
    type: number
    sql: ${TABLE}."PAYMENT_METHOD_ID" ;;
  }
  dimension: pdf_snapshot_url {
    type: string
    sql: ${TABLE}."PDF_SNAPSHOT_URL" ;;
  }
  dimension: personal_guarantee_address {
    type: string
    sql: ${TABLE}."PERSONAL_GUARANTEE_ADDRESS" ;;
  }
  dimension: personal_guarantee_city {
    type: string
    sql: ${TABLE}."PERSONAL_GUARANTEE_CITY" ;;
  }
  dimension: personal_guarantee_state_id {
    type: number
    sql: ${TABLE}."PERSONAL_GUARANTEE_STATE_ID" ;;
  }
  dimension: personal_guarantee_username {
    type: string
    sql: ${TABLE}."PERSONAL_GUARANTEE_USERNAME" ;;
  }
  dimension: personal_guarantee_zip_code {
    type: string
    sql: ${TABLE}."PERSONAL_GUARANTEE_ZIP_CODE" ;;
  }
  dimension: sales_person_email {
    type: string
    sql: ${TABLE}."SALES_PERSON_EMAIL" ;;
  }
  dimension: sales_person_first_name {
    type: string
    sql: ${TABLE}."SALES_PERSON_FIRST_NAME" ;;
  }
  dimension: sales_person_last_name {
    type: string
    sql: ${TABLE}."SALES_PERSON_LAST_NAME" ;;
  }
  dimension: sales_staff_exists {
    type: yesno
    sql: ${TABLE}."SALES_STAFF_EXISTS" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: submitting_user_name {
    type: string
    sql: ${TABLE}."SUBMITTING_USER_NAME" ;;
  }
  dimension: updated_by_user_id {
    type: number
    sql: ${TABLE}."UPDATED_BY_USER_ID" ;;
  }
  dimension: years_in_business {
    type: string
    sql: ${TABLE}."YEARS_IN_BUSINESS" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  credit_application_id,
  personal_guarantee_username,
  sales_person_last_name,
  account_payable_contact_first_name,
  sales_person_first_name,
  submitting_user_name,
  account_payable_contact_last_name,
  insurance_contact_first_name,
  business_legal_name,
  contact_name,
  insurance_contact_last_name
  ]
  }

}
