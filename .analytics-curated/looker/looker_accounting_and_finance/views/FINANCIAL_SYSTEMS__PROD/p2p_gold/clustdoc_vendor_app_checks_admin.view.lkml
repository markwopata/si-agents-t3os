view: clustdoc_vendor_app_checks_admin {
  sql_table_name: "P2P_GOLD"."CLUSTDOC_VENDOR_APP_CHECKS_ADMIN" ;;

  dimension: accepted_tcs {
    type: string
    sql: ${TABLE}."ACCEPTED_TCS" ;;
  }
  dimension: ach_notification_email {
    type: string
    sql: ${TABLE}."ACH_NOTIFICATION_EMAIL" ;;
  }
  dimension: ach_routing {
    type: string
    sql: ${TABLE}."ACH_ROUTING" ;;
  }
  dimension: address_line_1 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_1" ;;
  }
  dimension: address_line_2 {
    type: string
    sql: ${TABLE}."ADDRESS_LINE_2" ;;
  }
  dimension: application_data_issues {
    type: string
    sql: ${TABLE}."APPLICATION_DATA_ISSUES" ;;
  }
  dimension: application_title {
    type: string
    sql: ${TABLE}."APPLICATION_TITLE" ;;
  }
  dimension: approved_entities {
    type: string
    sql: ${TABLE}."APPROVED_ENTITIES" ;;
  }
  dimension: ar_business_phone {
    type: string
    sql: ${TABLE}."AR_BUSINESS_PHONE" ;;
  }
  dimension: ar_business_phone_ext {
    type: string
    sql: ${TABLE}."AR_BUSINESS_PHONE_EXT" ;;
  }
  dimension: ar_email {
    type: string
    sql: ${TABLE}."AR_EMAIL" ;;
  }
  dimension: ar_fax {
    type: string
    sql: ${TABLE}."AR_FAX" ;;
  }
  dimension: ar_first_name {
    type: string
    sql: ${TABLE}."AR_FIRST_NAME" ;;
  }
  dimension: ar_last_name {
    type: string
    sql: ${TABLE}."AR_LAST_NAME" ;;
  }
  dimension: bank_name {
    type: string
    sql: ${TABLE}."BANK_NAME" ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: clustdoc_owner {
    type: string
    sql: ${TABLE}."CLUSTDOC_OWNER" ;;
  }
  dimension: coi_tag {
    type: string
    sql: ${TABLE}."COI_TAG" ;;
  }
  dimension: commodity {
    type: string
    sql: ${TABLE}."COMMODITY" ;;
  }
  dimension: company_name_check {
    type: string
    sql: ${TABLE}."COMPANY_NAME_CHECK" ;;
  }
  dimension: confirm_ach_routing {
    type: string
    sql: ${TABLE}."CONFIRM_ACH_ROUTING" ;;
  }
  dimension: count_application_issues {
    type: number
    sql: ${TABLE}."COUNT_APPLICATION_ISSUES" ;;
  }
  dimension: count_application_items {
    type: number
    sql: ${TABLE}."COUNT_APPLICATION_ITEMS" ;;
  }
  dimension: count_hyphenless_tax_id_char {
    type: number
    value_format_name: id
    sql: ${TABLE}."COUNT_HYPHENLESS_TAX_ID_CHAR" ;;
  }
  dimension: count_open_items {
    type: number
    sql: ${TABLE}."COUNT_OPEN_ITEMS" ;;
  }
  dimension: count_rout_num_char {
    type: number
    sql: ${TABLE}."COUNT_ROUT_NUM_CHAR" ;;
  }
  dimension: count_vendors_matching_app_tax_id {
    type: number
    sql: ${TABLE}."COUNT_VENDORS_MATCHING_APP_TAX_ID" ;;
  }
  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }
  dimension: cs_business_phone {
    type: string
    sql: ${TABLE}."CS_BUSINESS_PHONE" ;;
  }
  dimension: cs_business_phone_ext {
    type: string
    sql: ${TABLE}."CS_BUSINESS_PHONE_EXT" ;;
  }
  dimension: cs_email {
    type: string
    sql: ${TABLE}."CS_EMAIL" ;;
  }
  dimension: cs_fax {
    type: string
    sql: ${TABLE}."CS_FAX" ;;
  }
  dimension: cs_first_name {
    type: string
    sql: ${TABLE}."CS_FIRST_NAME" ;;
  }
  dimension: cs_job_title {
    type: string
    sql: ${TABLE}."CS_JOB_TITLE" ;;
  }
  dimension: cs_last_name {
    type: string
    sql: ${TABLE}."CS_LAST_NAME" ;;
  }
  dimension: days_until_deadline {
    type: number
    sql: ${TABLE}."DAYS_UNTIL_DEADLINE" ;;
  }
  dimension: default_pay_method {
    type: string
    sql: ${TABLE}."DEFAULT_PAY_METHOD" ;;
  }
  dimension: diverse_business_class {
    type: string
    sql: ${TABLE}."DIVERSE_BUSINESS_CLASS" ;;
  }
  dimension: email_check {
    type: string
    sql: ${TABLE}."EMAIL_CHECK" ;;
  }
  dimension: eqs_contact {
    type: string
    sql: ${TABLE}."EQS_CONTACT" ;;
  }
  dimension: fee_percentage {
    type: string
    sql: ${TABLE}."FEE_PERCENTAGE" ;;
  }
  dimension: fk_template_id {
    type: number
    sql: ${TABLE}."FK_TEMPLATE_ID" ;;
  }
  dimension: id_existing_vendor {
    type: string
    sql: ${TABLE}."ID_EXISTING_VENDOR" ;;
  }
  dimension: id_vendors_matching_app_tax_id {
    type: string
    sql: ${TABLE}."ID_VENDORS_MATCHING_APP_TAX_ID" ;;
  }
  dimension: include_app {
    type: number
    sql: ${TABLE}."INCLUDE_APP" ;;
  }
  dimension: invoicing_email {
    type: string
    sql: ${TABLE}."INVOICING_EMAIL" ;;
  }
  dimension: is_acct_num_contains_non_numeric {
    type: number
    sql: ${TABLE}."IS_ACCT_NUM_CONTAINS_NON_NUMERIC" ;;
  }
  dimension: is_acct_num_less_5_char {
    type: number
    sql: ${TABLE}."IS_ACCT_NUM_LESS_5_CHAR" ;;
  }
  dimension: is_acct_num_mismatching_confirm {
    type: number
    sql: ${TABLE}."IS_ACCT_NUM_MISMATCHING_CONFIRM" ;;
  }
  dimension: is_acct_num_null {
    type: number
    sql: ${TABLE}."IS_ACCT_NUM_NULL" ;;
  }
  dimension: is_charge_fee {
    type: string
    sql: ${TABLE}."IS_CHARGE_FEE" ;;
  }
  dimension: is_email_invalid_ach {
    type: number
    sql: ${TABLE}."IS_EMAIL_INVALID_ACH" ;;
  }
  dimension: is_email_invalid_ar {
    type: number
    sql: ${TABLE}."IS_EMAIL_INVALID_AR" ;;
  }
  dimension: is_email_invalid_cs {
    type: number
    sql: ${TABLE}."IS_EMAIL_INVALID_CS" ;;
  }
  dimension: is_email_invalid_pc {
    type: number
    sql: ${TABLE}."IS_EMAIL_INVALID_PC" ;;
  }
  dimension: is_email_missing_ach {
    type: number
    sql: ${TABLE}."IS_EMAIL_MISSING_ACH" ;;
  }
  dimension: is_email_missing_ar {
    type: number
    sql: ${TABLE}."IS_EMAIL_MISSING_AR" ;;
  }
  dimension: is_email_missing_cs {
    type: number
    sql: ${TABLE}."IS_EMAIL_MISSING_CS" ;;
  }
  dimension: is_email_missing_pc {
    type: number
    sql: ${TABLE}."IS_EMAIL_MISSING_PC" ;;
  }
  dimension: is_existing_vendor {
    type: string
    sql: ${TABLE}."IS_EXISTING_VENDOR" ;;
  }
  dimension: is_existing_vendor_no_but_in_sage {
    type: number
    sql: ${TABLE}."IS_EXISTING_VENDOR_NO_BUT_IN_SAGE" ;;
  }
  dimension: is_existing_vendor_no_but_populated {
    type: number
    sql: ${TABLE}."IS_EXISTING_VENDOR_NO_BUT_POPULATED" ;;
  }
  dimension: is_existing_vendor_yes_but_null {
    type: number
    sql: ${TABLE}."IS_EXISTING_VENDOR_YES_BUT_NULL" ;;
  }
  dimension: is_existing_vendor_yes_not_in_sage {
    type: number
    sql: ${TABLE}."IS_EXISTING_VENDOR_YES_NOT_IN_SAGE" ;;
  }
  dimension: is_hauler {
    type: string
    sql: ${TABLE}."IS_HAULER" ;;
  }
  dimension: is_id_existing_vendor_invalid_format {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_ID_EXISTING_VENDOR_INVALID_FORMAT" ;;
  }
  dimension: is_in_possession_of_eqs_equipment {
    type: string
    sql: ${TABLE}."IS_IN_POSSESSION_OF_EQS_EQUIPMENT" ;;
  }
  dimension: is_late {
    type: string
    sql: ${TABLE}."IS_LATE" ;;
  }
  dimension: is_minority_special_status {
    type: string
    sql: ${TABLE}."IS_MINORITY_SPECIAL_STATUS" ;;
  }
  dimension: is_org_type_null {
    type: number
    sql: ${TABLE}."IS_ORG_TYPE_NULL" ;;
  }
  dimension: is_org_type_other {
    type: number
    sql: ${TABLE}."IS_ORG_TYPE_OTHER" ;;
  }
  dimension: is_recipient_notified {
    type: number
    sql: ${TABLE}."IS_RECIPIENT_NOTIFIED" ;;
  }
  dimension: is_related_party {
    type: string
    sql: ${TABLE}."IS_RELATED_PARTY" ;;
  }
  dimension: is_rout_num_contains_non_numeric {
    type: number
    sql: ${TABLE}."IS_ROUT_NUM_CONTAINS_NON_NUMERIC" ;;
  }
  dimension: is_rout_num_invalid {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_ROUT_NUM_INVALID" ;;
  }
  dimension: is_rout_num_mismatching_confirm {
    type: number
    sql: ${TABLE}."IS_ROUT_NUM_MISMATCHING_CONFIRM" ;;
  }
  dimension: is_rout_num_not_9_char {
    type: number
    sql: ${TABLE}."IS_ROUT_NUM_NOT_9_CHAR" ;;
  }
  dimension: is_rout_num_null {
    type: number
    sql: ${TABLE}."IS_ROUT_NUM_NULL" ;;
  }
  dimension: is_sage_app_null {
    type: number
    sql: ${TABLE}."IS_SAGE_APP_NULL" ;;
  }
  dimension: is_tax_exemption_required {
    type: string
    sql: ${TABLE}."IS_TAX_EXEMPTION_REQUIRED" ;;
  }
  dimension: is_tax_id_already_in_sage {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_ALREADY_IN_SAGE" ;;
  }
  dimension: is_tax_id_contains_non_numeric {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_CONTAINS_NON_NUMERIC" ;;
  }
  dimension: is_tax_id_hyphen_misplaced {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_HYPHEN_MISPLACED" ;;
  }
  dimension: is_tax_id_invalid {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_INVALID" ;;
  }
  dimension: is_tax_id_missing_hyphens {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_MISSING_HYPHENS" ;;
  }
  dimension: is_tax_id_not_9_char {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_NOT_9_CHAR" ;;
  }
  dimension: is_tax_id_null {
    type: number
    value_format_name: id
    sql: ${TABLE}."IS_TAX_ID_NULL" ;;
  }
  dimension: is_willing_to_file_ucc {
    type: string
    sql: ${TABLE}."IS_WILLING_TO_FILE_UCC" ;;
  }
  dimension: is_work_performed_at_eqs {
    type: string
    sql: ${TABLE}."IS_WORK_PERFORMED_AT_EQS" ;;
  }
  dimension: is_work_performed_not_at_eqs {
    type: string
    sql: ${TABLE}."IS_WORK_PERFORMED_NOT_AT_EQS" ;;
  }
  dimension: masked_ach_account {
    type: string
    sql: ${TABLE}."MASKED_ACH_ACCOUNT" ;;
  }
  dimension: masked_confirm_ach_account {
    type: string
    sql: ${TABLE}."MASKED_CONFIRM_ACH_ACCOUNT" ;;
  }
  dimension: id_tax_clustdoc {
    type: string
    sql: ${TABLE}."ID_TAX_CLUSTDOC" ;;
  }
  dimension: id_tax_sage {
    type: string
    sql: ${TABLE}."ID_TAX_SAGE" ;;
  }
  dimension: masked_id_tax_clustdoc {
    type: string
    sql: ${TABLE}."MASKED_ID_TAX_CLUSTDOC" ;;
  }
  dimension: masked_id_tax_sage {
    type: string
    sql: ${TABLE}."MASKED_ID_TAX_SAGE" ;;
  }
  dimension: name_dba {
    type: string
    sql: ${TABLE}."NAME_DBA" ;;
  }
  dimension: name_legal {
    type: string
    sql: ${TABLE}."NAME_LEGAL" ;;
  }
  dimension: name_tag {
    type: string
    sql: ${TABLE}."NAME_TAG" ;;
  }
  dimension: org_type {
    type: string
    sql: ${TABLE}."ORG_TYPE" ;;
  }
  dimension: org_type_explanation {
    type: string
    sql: ${TABLE}."ORG_TYPE_EXPLANATION" ;;
  }
  dimension: other_tag {
    type: string
    sql: ${TABLE}."OTHER_TAG" ;;
  }
  dimension: pc_business_phone {
    type: string
    sql: ${TABLE}."PC_BUSINESS_PHONE" ;;
  }
  dimension: pc_business_phone_ext {
    type: string
    sql: ${TABLE}."PC_BUSINESS_PHONE_EXT" ;;
  }
  dimension: pc_email {
    type: string
    sql: ${TABLE}."PC_EMAIL" ;;
  }
  dimension: pc_fax {
    type: string
    sql: ${TABLE}."PC_FAX" ;;
  }
  dimension: pc_first_name {
    type: string
    sql: ${TABLE}."PC_FIRST_NAME" ;;
  }
  dimension: pc_last_name {
    type: string
    sql: ${TABLE}."PC_LAST_NAME" ;;
  }
  dimension: pc_mobile_phone {
    type: string
    sql: ${TABLE}."PC_MOBILE_PHONE" ;;
  }
  dimension: pc_mobile_phone_ext {
    type: string
    sql: ${TABLE}."PC_MOBILE_PHONE_EXT" ;;
  }
  dimension: pc_referral {
    type: string
    sql: ${TABLE}."PC_REFERRAL" ;;
  }
  dimension: pc_title {
    type: string
    sql: ${TABLE}."PC_TITLE" ;;
  }
  dimension: phone_check {
    type: string
    sql: ${TABLE}."PHONE_CHECK" ;;
  }
  dimension: pk_application_id {
    type: number
    sql: ${TABLE}."PK_APPLICATION_ID" ;;
  }
  dimension: reason_for_app_inclusion {
    type: string
    sql: ${TABLE}."REASON_FOR_APP_INCLUSION" ;;
  }
  dimension: remit_city {
    type: string
    sql: ${TABLE}."REMIT_CITY" ;;
  }
  dimension: remit_country {
    type: string
    sql: ${TABLE}."REMIT_COUNTRY" ;;
  }
  dimension: remit_line_1 {
    type: string
    sql: ${TABLE}."REMIT_LINE_1" ;;
  }
  dimension: remit_line_2 {
    type: string
    sql: ${TABLE}."REMIT_LINE_2" ;;
  }
  dimension: remit_state {
    type: string
    sql: ${TABLE}."REMIT_STATE" ;;
  }
  dimension: remit_zip {
    type: string
    sql: ${TABLE}."REMIT_ZIP" ;;
  }
  dimension: stage {
    type: string
    sql: ${TABLE}."STAGE" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: tags {
    type: string
    sql: ${TABLE}."TAGS" ;;
  }
  dimension: tax_id_check {
    type: string
    sql: ${TABLE}."TAX_ID_CHECK" ;;
  }
dimension_group: timestamp_client_modified {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_CLIENT_MODIFIED") ;;
}
dimension_group: timestamp_closed {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_CLOSED") ;;
}
dimension_group: timestamp_created {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_CREATED") ;;
}
dimension_group: timestamp_deadline {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_DEADLINE") ;;
}
dimension_group: timestamp_deleted {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_DELETED") ;;
}
dimension_group: timestamp_last_updated_clustdoc {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_LAST_UPDATED_CLUSTDOC") ;;
}
dimension_group: timestamp_latest_linked_app_sage {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_LATEST_LINKED_APP_SAGE") ;;
}
dimension_group: timestamp_loaded {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_LOADED") ;;
}
dimension_group: timestamp_modified {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_MODIFIED") ;;
}
dimension_group: timestamp_submitted {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_SUBMITTED") ;;
}
dimension_group: timestamp_terms_accepted {
  type: time
  timeframes: [raw, time, date, week, month, quarter, year]
  sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_TERMS_ACCEPTED") ;;
}
  dimension: url_application {
    type: string
    sql: ${TABLE}."URL_APPLICATION" ;;
    link: {
      label: "Open Application"
      url: "{{ value }}"
    }
  }
  dimension: url_clustdoc_app {
    type: string
    sql: ${TABLE}."URL_CLUSTDOC_APP" ;;
  }
  dimension: url_clustdoc_app_blue {
    type: string
    sql: ${TABLE}."URL_CLUSTDOC_APP" ;;

    html: "
    <a href='https://{{ value }}' target='_blank' style='color: blue;'>
    {{ value }}
    </a>
    ";;
  }
  dimension: url_clustdoc_app_grey {
    type: string
    sql: ${TABLE}."URL_CLUSTDOC_APP" ;;
    link: {
      label: "Open Application"
      url: "https://{{ value }}"
    }
  }
  dimension: url_vendor_website {
    type: string
    sql: ${TABLE}."URL_VENDOR_WEBSITE" ;;
  }
  dimension: validation_flag {
    type: string
    sql: ${TABLE}."VALIDATION_FLAG" ;;
  }
  dimension: vendor_category_legacy {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY_LEGACY" ;;
  }
  dimension: vendor_category_new {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY_NEW" ;;
  }
  dimension: vendor_subcategory {
    type: string
    sql: ${TABLE}."VENDOR_SUBCATEGORY" ;;
  }
  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  ar_first_name,
  bank_name,
  cs_last_name,
  ar_last_name,
  cs_first_name,
  pc_last_name,
  pc_first_name
  ]
  }

}
