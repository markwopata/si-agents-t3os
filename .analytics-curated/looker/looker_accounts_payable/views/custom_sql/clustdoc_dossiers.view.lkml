view: clustdoc_dossiers {
  derived_table: {
    sql:
    SELECT *
    FROM ANALYTICS.CLUSTDOC.DOSSIER_EXTRACT
    ;;
  }

  dimension: application_id {
    type: string
    sql: ${TABLE}.APPLICATION_ID ;;
  }

  dimension: application_url {
    type: string
    sql: ${TABLE}.APPLICATION_URL ;;
  }

  dimension: application_title {
    type: string
    sql: ${TABLE}.APPLICATION_TITLE ;;
  }

  dimension: template_id {
    type: number
    sql: ${TABLE}.TEMPLATE_ID ;;
  }

  dimension_group: created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.CREATED_AT ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.UPDATED_AT ;;
  }

  dimension_group: deleted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DELETED_AT ;;
  }

  dimension_group: closed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.CLOSED_AT ;;
  }

  dimension_group: submitted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.SUBMITTED_AT ;;
  }

  dimension_group: terms_accepted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.TERMS_ACCEPTED_AT ;;
  }

  dimension_group: client_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.CLIENT_UPDATED_AT ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.STATUS ;;
  }

  dimension: stage {
    type: string
    sql: ${TABLE}.STAGE ;;
  }

  dimension: recipient_notified {
    type: number
    sql: ${TABLE}.RECIPIENT_NOTIFIED ;;
  }

  dimension: eqs_contact {
    type: string
    sql: ${TABLE}.EQS_CONTACT ;;
  }

  dimension: deadline {
    type: date
    sql: ${TABLE}.DEADLINE ;;
  }

  dimension: days_until_deadline {
    type: number
    sql: ${TABLE}.DAYS_UNTIL_DEADLINE ;;
  }

  dimension: is_late {
    type: yesno
    sql: ${TABLE}.IS_LATE ;;
  }

  dimension: owner {
    type: string
    sql: ${TABLE}.OWNER ;;
  }

  dimension: tags {
    type: string
    sql: ${TABLE}.TAGS ;;
  }

  dimension: accepted_tcs {
    type: string
    sql: ${TABLE}.ACCEPTED_TCS ;;
  }

  dimension: approved_entities {
    type: string
    sql: ${TABLE}.APPROVED_ENTITIES ;;
  }

  dimension: is_existing_vendor {
    type: string
    sql: ${TABLE}.IS_EXISTING_VENDOR ;;
  }

  dimension: existing_vendor_id {
    type: string
    sql: ${TABLE}.EXISTING_VENDOR_ID ;;
  }

  dimension: vendor_category_new {
    type: string
    sql: ${TABLE}.VENDOR_CATEGORY_NEW ;;
  }

  dimension: vendor_category_legacy {
    type: string
    sql: ${TABLE}.VENDOR_CATEGORY_LEGACY ;;
  }

  dimension: vendor_subcategory {
    type: string
    sql: ${TABLE}.VENDOR_SUBCATEGORY ;;
  }

  dimension: legal_name {
    type: string
    sql: ${TABLE}.LEGAL_NAME ;;
  }

  dimension: dba_name {
    type: string
    sql: ${TABLE}.DBA_NAME ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.COUNTRY ;;
  }

  dimension: address_line_1 {
    type: string
    sql: ${TABLE}.ADDRESS_LINE_1 ;;
  }

  dimension: address_line_2 {
    type: string
    sql: ${TABLE}.ADDRESS_LINE_2 ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.CITY ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.STATE ;;
  }

  dimension: zip {
    type: string
    sql: ${TABLE}.ZIP ;;
  }

  dimension: website {
    type: string
    sql: ${TABLE}.WEBSITE ;;
  }

  dimension: org_type {
    type: string
    sql: ${TABLE}.ORG_TYPE ;;
  }

  dimension: org_type_explanation {
    type: string
    sql: ${TABLE}.ORG_TYPE_EXPLANATION ;;
  }

  dimension: tax_id {
    type: string
    sql: ${TABLE}.TAX_ID ;;
  }

  dimension: in_possession_of_eqs_equipment {
    type: string
    sql: ${TABLE}.IN_POSSESSION_OF_EQS_EQUIPMENT ;;
  }

  dimension: transport_or_equipment_hauler {
    type: string
    sql: ${TABLE}.TRANSPORT_OR_EQUIPMENT_HAULER ;;
  }

  dimension: perform_work_at_eqs {
    type: string
    sql: ${TABLE}.PERFORM_WORK_AT_EQS ;;
  }

  dimension: perform_work_not_at_eqs {
    type: string
    sql: ${TABLE}.PERFORM_WORK_NOT_AT_EQS ;;
  }

  dimension: commodity {
    type: string
    sql: ${TABLE}.COMMODITY ;;
  }

  dimension: minority_special_status {
    type: string
    sql: ${TABLE}.MINORITY_SPECIAL_STATUS ;;
  }

  dimension: diverse_business_class {
    type: string
    sql: ${TABLE}.DIVERSE_BUSINESS_CLASS ;;
  }

  dimension: will_file_ucc {
    type: string
    sql: ${TABLE}.WILL_FILE_UCC ;;
  }

  dimension: is_related_party {
    type: string
    sql: ${TABLE}.IS_RELATED_PARTY ;;
  }

  dimension: pc_first_name {
    type: string
    sql: ${TABLE}.PC_FIRST_NAME ;;
  }

  dimension: pc_last_name {
    type: string
    sql: ${TABLE}.PC_LAST_NAME ;;
  }

  dimension: pc_title {
    type: string
    sql: ${TABLE}.PC_TITLE ;;
  }

  dimension: pc_business_phone {
    type: string
    sql: ${TABLE}.PC_BUSINESS_PHONE ;;
  }

  dimension: pc_mobile_phone {
    type: string
    sql: ${TABLE}.PC_MOBILE_PHONE ;;
  }

  dimension: pc_email {
    type: string
    sql: ${TABLE}.PC_EMAIL ;;
  }

  dimension: pc_fax {
    type: string
    sql: ${TABLE}.PC_FAX ;;
  }

  dimension: pc_referral {
    type: string
    sql: ${TABLE}.PC_REFERRAL ;;
  }

  dimension: ar_first_name {
    type: string
    sql: ${TABLE}.AR_FIRST_NAME ;;
  }

  dimension: ar_last_name {
    type: string
    sql: ${TABLE}.AR_LAST_NAME ;;
  }

  dimension: ar_business_phone {
    type: string
    sql: ${TABLE}.AR_BUSINESS_PHONE ;;
  }

  dimension: ar_email {
    type: string
    sql: ${TABLE}.AR_EMAIL ;;
  }

  dimension: ar_fax {
    type: string
    sql: ${TABLE}.AR_FAX ;;
  }

  dimension: cs_first_name {
    type: string
    sql: ${TABLE}.CS_FIRST_NAME ;;
  }

  dimension: cs_last_name {
    type: string
    sql: ${TABLE}.CS_LAST_NAME ;;
  }

  dimension: cs_job_title {
    type: string
    sql: ${TABLE}.CS_JOB_TITLE ;;
  }

  dimension: cs_business_phone {
    type: string
    sql: ${TABLE}.CS_BUSINESS_PHONE ;;
  }

  dimension: cs_email {
    type: string
    sql: ${TABLE}.CS_EMAIL ;;
  }

  dimension: cs_fax {
    type: string
    sql: ${TABLE}.CS_FAX ;;
  }

  dimension: default_pay_method {
    type: string
    sql: ${TABLE}.DEFAULT_PAY_METHOD ;;
  }

  dimension: ach_notification_email {
    type: string
    sql: ${TABLE}.ACH_NOTIFICATION_EMAIL ;;
  }

  dimension: bank_name {
    type: string
    sql: ${TABLE}.BANK_NAME ;;
  }

  dimension: ach_routing {
    type: string
    sql: ${TABLE}.ACH_ROUTING ;;
  }

  dimension: confirm_ach_routing {
    type: string
    sql: ${TABLE}.CONFIRM_ACH_ROUTING ;;
  }

  dimension: ach_account {
    type: string
    sql: ${TABLE}.ACH_ACCOUNT ;;
  }

  dimension: confirm_ach_account {
    type: string
    sql: ${TABLE}.CONFIRM_ACH_ACCOUNT ;;
  }

  dimension: charge_fee {
    type: string
    sql: ${TABLE}.CHARGE_FEE ;;
  }

  dimension: fee_percentage {
    type: string
    sql: ${TABLE}.FEE_PERCENTAGE ;;
  }

  dimension: remit_line_1 {
    type: string
    sql: ${TABLE}.REMIT_LINE_1 ;;
  }

  dimension: remit_line_2 {
    type: string
    sql: ${TABLE}.REMIT_LINE_2 ;;
  }

  dimension: remit_city {
    type: string
    sql: ${TABLE}.REMIT_CITY ;;
  }

  dimension: remit_state {
    type: string
    sql: ${TABLE}.REMIT_STATE ;;
  }

  dimension: remit_zip {
    type: string
    sql: ${TABLE}.REMIT_ZIP ;;
  }

  dimension: remit_country {
    type: string
    sql: ${TABLE}.REMIT_COUNTRY ;;
  }

  dimension: invoicing_email {
    type: string
    sql: ${TABLE}.INVOICING_EMAIL ;;
  }

  dimension: requires_tax_exemption {
    type: string
    sql: ${TABLE}.REQUIRES_TAX_EXEMPTION ;;
  }

  dimension: count_application_items {
    type: number
    sql: ${TABLE}.COUNT_APPLICATION_ITEMS ;;
  }

  dimension: count_open_items {
    type: number
    sql: ${TABLE}.COUNT_OPEN_ITEMS ;;
  }

  dimension: application_data_issues {
    type: string
    sql: ${TABLE}.APPLICATION_DATA_ISSUES ;;
  }

  dimension: es_update_timestamp {
    type: date
    sql: ${TABLE}._ES_UPDATE_TIMESTAMP ;;
  }

  measure: applications_created {
    type: count
    drill_fields: [
      application_id,
      application_title,
      status,
      stage
    ]
  }

}
