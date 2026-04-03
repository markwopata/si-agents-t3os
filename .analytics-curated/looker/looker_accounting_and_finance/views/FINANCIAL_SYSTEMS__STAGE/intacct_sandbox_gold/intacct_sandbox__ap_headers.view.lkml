view: intacct_sandbox__ap_headers {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__AP_HEADERS" ;;

  dimension: account_paid_from {
    type: string
    sql: ${TABLE}."ACCOUNT_PAID_FROM" ;;
  }
  dimension: amount_payment {
    type: number
    sql: ${TABLE}."AMOUNT_PAYMENT" ;;
  }
  dimension: amount_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_DUE" ;;
  }
  dimension: amount_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_ENTERED" ;;
  }
  dimension: amount_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
  }
  dimension: amount_total_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_RETAINED" ;;
  }
  dimension: amount_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
  }
  dimension: amount_trx_entity_due {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_ENTITY_DUE" ;;
  }
  dimension: amount_trx_total_due {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_DUE" ;;
  }
  dimension: amount_trx_total_entered {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_ENTERED" ;;
  }
  dimension: amount_trx_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
  }
  dimension: amount_trx_total_released {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RELEASED" ;;
  }
  dimension: amount_trx_total_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_RETAINED" ;;
  }
  dimension: amount_trx_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
  }
  dimension_group: date_advance {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ADVANCE" ;;
  }
  dimension_group: date_cleared {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CLEARED" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_discount {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DISCOUNT" ;;
  }
  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
  }
  dimension_group: date_paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAID" ;;
  }
  dimension_group: date_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT" ;;
  }
  dimension_group: date_payment_recommended {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT_RECOMMENDED" ;;
  }
  dimension_group: date_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTED" ;;
  }
  dimension_group: date_receipt {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECEIPT" ;;
  }
  dimension_group: date_reconciled {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECONCILED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: document_number {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER" ;;
  }
  dimension: email_recipient {
    type: string
    sql: ${TABLE}."EMAIL_RECIPIENT" ;;
  }
  dimension: email_sender {
    type: string
    sql: ${TABLE}."EMAIL_SENDER" ;;
  }
  dimension: fk_bill_back_record_id {
    type: string
    sql: ${TABLE}."FK_BILL_BACK_RECORD_ID" ;;
  }
  dimension: fk_bill_pay_to_contact_id {
    type: number
    sql: ${TABLE}."FK_BILL_PAY_TO_CONTACT_ID" ;;
  }
  dimension: fk_concur_image_id {
    type: string
    sql: ${TABLE}."FK_CONCUR_IMAGE_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_doc_header_id {
    type: string
    sql: ${TABLE}."FK_DOC_HEADER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_pay_to_tax_group_record_id {
    type: string
    sql: ${TABLE}."FK_PAY_TO_TAX_GROUP_RECORD_ID" ;;
  }
  dimension: fk_payment_method_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_METHOD_ID" ;;
  }
  dimension: fk_payment_term_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_TERM_ID" ;;
  }
  dimension: fk_pr_batch_id {
    type: number
    sql: ${TABLE}."FK_PR_BATCH_ID" ;;
  }
  dimension: fk_ship_return_contact_id {
    type: number
    sql: ${TABLE}."FK_SHIP_RETURN_CONTACT_ID" ;;
  }
  dimension: fk_user_id {
    type: string
    sql: ${TABLE}."FK_USER_ID" ;;
  }
  dimension: fk_user_key {
    type: number
    sql: ${TABLE}."FK_USER_KEY" ;;
  }
  dimension: fk_vendor_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_ID" ;;
  }
  dimension: form_1099_box {
    type: string
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }
  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }
  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: is_bill_back_template_use_iet {
    type: yesno
    sql: ${TABLE}."IS_BILL_BACK_TEMPLATE_USE_IET" ;;
  }
  dimension: is_inclusive_tax {
    type: yesno
    sql: ${TABLE}."IS_INCLUSIVE_TAX" ;;
  }
  dimension: is_on_hold {
    type: yesno
    sql: ${TABLE}."IS_ON_HOLD" ;;
  }
  dimension: is_pr_batch_no_gl {
    type: yesno
    sql: ${TABLE}."IS_PR_BATCH_NO_GL" ;;
  }
  dimension: is_retainage_released {
    type: yesno
    sql: ${TABLE}."IS_RETAINAGE_RELEASED" ;;
  }
  dimension: is_system_generated {
    type: string
    sql: ${TABLE}."IS_SYSTEM_GENERATED" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: name_module {
    type: string
    sql: ${TABLE}."NAME_MODULE" ;;
  }
  dimension: name_pr_batch {
    type: string
    sql: ${TABLE}."NAME_PR_BATCH" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: pk_ap_header_id {
    type: number
    sql: ${TABLE}."PK_AP_HEADER_ID" ;;
  }
  dimension: state_raw {
    type: string
    sql: ${TABLE}."STATE_RAW" ;;
  }
  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
  }
  dimension: status_cleared {
    type: string
    sql: ${TABLE}."STATUS_CLEARED" ;;
  }
  dimension: status_record {
    type: string
    sql: ${TABLE}."STATUS_RECORD" ;;
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
  dimension: type_payment {
    type: string
    sql: ${TABLE}."TYPE_PAYMENT" ;;
  }
  dimension: type_record {
    type: string
    sql: ${TABLE}."TYPE_RECORD" ;;
  }
  dimension: type_vendor_1099 {
    type: string
    sql: ${TABLE}."TYPE_VENDOR_1099" ;;
  }
  dimension: url_bill_image {
    type: string
    sql: ${TABLE}."URL_BILL_IMAGE" ;;
  }
  dimension: url_yooz {
    type: string
    sql: ${TABLE}."URL_YOOZ" ;;
  }
  measure: count {
    type: count
  }
}
