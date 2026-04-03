view: intacct_sandbox__vendors {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__VENDORS" ;;

  dimension: ach_account_number {
    type: number
    sql: ${TABLE}."ACH_ACCOUNT_NUMBER" ;;
  }
  dimension: ach_prenote_account_number {
    type: number
    sql: ${TABLE}."ACH_PRENOTE_ACCOUNT_NUMBER" ;;
  }
  dimension: ach_prenote_last_auth_account_number {
    type: number
    sql: ${TABLE}."ACH_PRENOTE_LAST_AUTH_ACCOUNT_NUMBER" ;;
  }
  dimension: ach_prenote_routing_number {
    type: number
    sql: ${TABLE}."ACH_PRENOTE_ROUTING_NUMBER" ;;
  }
  dimension: ach_routing_number {
    type: number
    sql: ${TABLE}."ACH_ROUTING_NUMBER" ;;
  }
  dimension: amount_credit_limit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT_LIMIT" ;;
  }
  dimension: amount_due {
    type: number
    sql: ${TABLE}."AMOUNT_DUE" ;;
  }
  dimension: approved_entities {
    type: string
    sql: ${TABLE}."APPROVED_ENTITIES" ;;
  }
  dimension: category_reporting {
    type: string
    sql: ${TABLE}."CATEGORY_REPORTING" ;;
  }
  dimension: category_vendor {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR" ;;
  }
  dimension: category_vendor_new {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_NEW" ;;
  }
  dimension: category_vendor_sub {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_SUB" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }
  dimension: commodity {
    type: string
    sql: ${TABLE}."COMMODITY" ;;
  }
  dimension_group: date_earliest_coi_expiration {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_COI_EXPIRATION" ;;
  }
  dimension_group: date_msa_valid_through {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_MSA_VALID_THROUGH" ;;
  }
  dimension_group: date_prenote_last_auth {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PRENOTE_LAST_AUTH" ;;
  }
  dimension: email_eqs_employee_notify_on_vendor_creation {
    type: string
    sql: ${TABLE}."EMAIL_EQS_EMPLOYEE_NOTIFY_ON_VENDOR_CREATION" ;;
  }
  dimension: email_vendor_invoices_from {
    type: string
    sql: ${TABLE}."EMAIL_VENDOR_INVOICES_FROM" ;;
  }
  dimension: email_vic_ap_rep_corp_cc {
    type: string
    sql: ${TABLE}."EMAIL_VIC_AP_REP_CORP_CC" ;;
  }
  dimension: email_vic_ap_rep_fleet {
    type: string
    sql: ${TABLE}."EMAIL_VIC_AP_REP_FLEET" ;;
  }
  dimension: fk_1099_contact_id {
    type: number
    sql: ${TABLE}."FK_1099_CONTACT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_crm_id {
    type: number
    sql: ${TABLE}."FK_CRM_ID" ;;
  }
  dimension: fk_display_contact_id {
    type: number
    sql: ${TABLE}."FK_DISPLAY_CONTACT_ID" ;;
  }
  dimension: fk_es_admin_id {
    type: number
    sql: ${TABLE}."FK_ES_ADMIN_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_fleet_track_id {
    type: number
    sql: ${TABLE}."FK_FLEET_TRACK_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_pay_to_contact_id {
    type: number
    sql: ${TABLE}."FK_PAY_TO_CONTACT_ID" ;;
  }
  dimension: fk_payment_method_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_METHOD_ID" ;;
  }
  dimension: fk_payment_term_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_TERM_ID" ;;
  }
  dimension: fk_primary_contact_id {
    type: number
    sql: ${TABLE}."FK_PRIMARY_CONTACT_ID" ;;
  }
  dimension: fk_return_to_contact_id {
    type: number
    sql: ${TABLE}."FK_RETURN_TO_CONTACT_ID" ;;
  }
  dimension: fk_vendor_portal_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_PORTAL_ID" ;;
  }
  dimension: fk_vendor_redirect_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_REDIRECT_ID" ;;
  }
  dimension: fk_vendor_type_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_TYPE_ID" ;;
  }
  dimension: fk_vic_ai_vendor_id {
    type: string
    sql: ${TABLE}."FK_VIC_AI_VENDOR_ID" ;;
  }
  dimension: fleet_book_of_business {
    type: string
    sql: ${TABLE}."FLEET_BOOK_OF_BUSINESS" ;;
  }
  dimension: fleet_category {
    type: string
    sql: ${TABLE}."FLEET_CATEGORY" ;;
  }
  dimension: fleet_core_designation {
    type: string
    sql: ${TABLE}."FLEET_CORE_DESIGNATION" ;;
  }
  dimension: fleet_financing_designation {
    type: string
    sql: ${TABLE}."FLEET_FINANCING_DESIGNATION" ;;
  }
  dimension: fleet_principal_or_agent {
    type: string
    sql: ${TABLE}."FLEET_PRINCIPAL_OR_AGENT" ;;
  }
  dimension: form_1099_box {
    type: number
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }
  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }
  dimension: id_document {
    type: string
    sql: ${TABLE}."ID_DOCUMENT" ;;
  }
  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }
  dimension: id_tax_foreign {
    type: string
    sql: ${TABLE}."ID_TAX_FOREIGN" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: is_ach_enabled {
    type: yesno
    sql: ${TABLE}."IS_ACH_ENABLED" ;;
  }
  dimension: is_bistrack {
    type: yesno
    sql: ${TABLE}."IS_BISTRACK" ;;
  }
  dimension: is_check_enabled {
    type: yesno
    sql: ${TABLE}."IS_CHECK_ENABLED" ;;
  }
  dimension: is_cip_vendor {
    type: yesno
    sql: ${TABLE}."IS_CIP_VENDOR" ;;
  }
  dimension: is_credit_card_vendor {
    type: yesno
    sql: ${TABLE}."IS_CREDIT_CARD_VENDOR" ;;
  }
  dimension: is_d365_dc {
    type: yesno
    sql: ${TABLE}."IS_D365_DC" ;;
  }
  dimension: is_d365_moberly {
    type: yesno
    sql: ${TABLE}."IS_D365_MOBERLY" ;;
  }
  dimension: is_display_loc_acct_no_check {
    type: yesno
    sql: ${TABLE}."IS_DISPLAY_LOC_ACCT_NO_CHECK" ;;
  }
  dimension: is_display_term_discount {
    type: yesno
    sql: ${TABLE}."IS_DISPLAY_TERM_DISCOUNT" ;;
  }
  dimension: is_do_not_cut_check {
    type: yesno
    sql: ${TABLE}."IS_DO_NOT_CUT_CHECK" ;;
  }
  dimension: is_fleet_track {
    type: yesno
    sql: ${TABLE}."IS_FLEET_TRACK" ;;
  }
  dimension: is_individual {
    type: yesno
    sql: ${TABLE}."IS_INDIVIDUAL" ;;
  }
  dimension: is_merge_payment_requests {
    type: yesno
    sql: ${TABLE}."IS_MERGE_PAYMENT_REQUESTS" ;;
  }
  dimension: is_non_inventory {
    type: yesno
    sql: ${TABLE}."IS_NON_INVENTORY" ;;
  }
  dimension: is_on_hold {
    type: yesno
    sql: ${TABLE}."IS_ON_HOLD" ;;
  }
  dimension: is_one_time_use {
    type: yesno
    sql: ${TABLE}."IS_ONE_TIME_USE" ;;
  }
  dimension: is_owner {
    type: yesno
    sql: ${TABLE}."IS_OWNER" ;;
  }
  dimension: is_payment_notify {
    type: yesno
    sql: ${TABLE}."IS_PAYMENT_NOTIFY" ;;
  }
  dimension: is_prevent_new_poe_in_sage {
    type: yesno
    sql: ${TABLE}."IS_PREVENT_NEW_POE_IN_SAGE" ;;
  }
  dimension: is_requires_coi {
    type: yesno
    sql: ${TABLE}."IS_REQUIRES_COI" ;;
  }
  dimension: is_t3_crm {
    type: yesno
    sql: ${TABLE}."IS_T3_CRM" ;;
  }
  dimension: name_dba {
    type: string
    sql: ${TABLE}."NAME_DBA" ;;
  }
  dimension: name_diversity_classification {
    type: string
    sql: ${TABLE}."NAME_DIVERSITY_CLASSIFICATION" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_file_payment_service {
    type: string
    sql: ${TABLE}."NAME_FILE_PAYMENT_SERVICE" ;;
  }
  dimension: name_legal {
    type: string
    sql: ${TABLE}."NAME_LEGAL" ;;
  }
  dimension: name_payment_term {
    type: string
    sql: ${TABLE}."NAME_PAYMENT_TERM" ;;
  }
  dimension: name_restricted_objects {
    type: string
    sql: ${TABLE}."NAME_RESTRICTED_OBJECTS" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: name_vendor_1099 {
    type: string
    sql: ${TABLE}."NAME_VENDOR_1099" ;;
  }
  dimension: num_days_epay_due_date_deduction {
    type: number
    sql: ${TABLE}."NUM_DAYS_EPAY_DUE_DATE_DEDUCTION" ;;
  }
  dimension: pk_vendor_id {
    type: number
    sql: ${TABLE}."PK_VENDOR_ID" ;;
  }
  dimension: priority_payment {
    type: string
    sql: ${TABLE}."PRIORITY_PAYMENT" ;;
  }
  dimension: status_vendor {
    type: string
    sql: ${TABLE}."STATUS_VENDOR" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }
  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: type_ach_account {
    type: string
    sql: ${TABLE}."TYPE_ACH_ACCOUNT" ;;
  }
  dimension: type_ach_remittance {
    type: string
    sql: ${TABLE}."TYPE_ACH_REMITTANCE" ;;
  }
  dimension: type_alt_pay_method {
    type: string
    sql: ${TABLE}."TYPE_ALT_PAY_METHOD" ;;
  }
  dimension: type_billing {
    type: string
    sql: ${TABLE}."TYPE_BILLING" ;;
  }
  dimension: type_organization {
    type: string
    sql: ${TABLE}."TYPE_ORGANIZATION" ;;
  }
  dimension: type_vendor {
    type: string
    sql: ${TABLE}."TYPE_VENDOR" ;;
  }
  dimension: url_coi {
    type: string
    sql: ${TABLE}."URL_COI" ;;
  }
  dimension: url_crm {
    type: string
    sql: ${TABLE}."URL_CRM" ;;
  }
  dimension: vendor_purchases_financed_by {
    type: string
    sql: ${TABLE}."VENDOR_PURCHASES_FINANCED_BY" ;;
  }
  measure: count {
    type: count
  }
}
