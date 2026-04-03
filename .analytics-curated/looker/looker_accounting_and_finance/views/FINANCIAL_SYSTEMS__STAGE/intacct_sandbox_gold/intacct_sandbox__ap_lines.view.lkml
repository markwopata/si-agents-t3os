view: intacct_sandbox__ap_lines {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__AP_LINES" ;;

  dimension: amount_line {
    type: number
    sql: ${TABLE}."AMOUNT_LINE" ;;
  }
  dimension: amount_retained {
    type: number
    sql: ${TABLE}."AMOUNT_RETAINED" ;;
  }
  dimension: amount_subtotal {
    type: number
    sql: ${TABLE}."AMOUNT_SUBTOTAL" ;;
  }
  dimension: amount_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
  }
  dimension: amount_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
  }
  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
  }
  dimension: amount_trx_released {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_RELEASED" ;;
  }
  dimension: amount_trx_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_RETAINED" ;;
  }
  dimension: amount_trx_total_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
  }
  dimension: amount_trx_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
  }
  dimension: box_form_1099 {
    type: string
    sql: ${TABLE}."BOX_FORM_1099" ;;
  }
  dimension_group: date_entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ENTRY" ;;
  }
  dimension: description_entry {
    type: string
    sql: ${TABLE}."DESCRIPTION_ENTRY" ;;
  }
  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
  }
  dimension: fk_class_dimension_id {
    type: string
    sql: ${TABLE}."FK_CLASS_DIMENSION_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_customer_dimension_id {
    type: string
    sql: ${TABLE}."FK_CUSTOMER_DIMENSION_ID" ;;
  }
  dimension: fk_department_id {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
  }
  dimension: fk_employee_dimension_id {
    type: string
    sql: ${TABLE}."FK_EMPLOYEE_DIMENSION_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_gl_account_id {
    type: string
    sql: ${TABLE}."FK_GL_ACCOUNT_ID" ;;
  }
  dimension: fk_item_dimension_id {
    type: string
    sql: ${TABLE}."FK_ITEM_DIMENSION_ID" ;;
  }
  dimension: fk_location_id {
    type: string
    sql: ${TABLE}."FK_LOCATION_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_original_doc_id {
    type: string
    sql: ${TABLE}."FK_ORIGINAL_DOC_ID" ;;
  }
  dimension: fk_original_doc_line_id {
    type: string
    sql: ${TABLE}."FK_ORIGINAL_DOC_LINE_ID" ;;
  }
  dimension: fk_vendor_dimension_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_DIMENSION_ID" ;;
  }
  dimension: flag_line_item {
    type: string
    sql: ${TABLE}."FLAG_LINE_ITEM" ;;
  }
  dimension: gldim_asset {
    type: string
    sql: ${TABLE}."GLDIM_ASSET" ;;
  }
  dimension: gldim_expense_line {
    type: string
    sql: ${TABLE}."GLDIM_EXPENSE_LINE" ;;
  }
  dimension: gldim_transaction_identifier {
    type: string
    sql: ${TABLE}."GLDIM_TRANSACTION_IDENTIFIER" ;;
  }
  dimension: gldim_ud_loan {
    type: string
    sql: ${TABLE}."GLDIM_UD_LOAN" ;;
  }
  dimension: id_asset {
    type: string
    sql: ${TABLE}."ID_ASSET" ;;
  }
  dimension: id_class {
    type: string
    sql: ${TABLE}."ID_CLASS" ;;
  }
  dimension: id_customer {
    type: string
    sql: ${TABLE}."ID_CUSTOMER" ;;
  }
  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }
  dimension: id_employee {
    type: string
    sql: ${TABLE}."ID_EMPLOYEE" ;;
  }
  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }
  dimension: id_original_doc {
    type: string
    sql: ${TABLE}."ID_ORIGINAL_DOC" ;;
  }
  dimension: id_original_doc_line {
    type: string
    sql: ${TABLE}."ID_ORIGINAL_DOC_LINE" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }
  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }
  dimension: number_line {
    type: string
    sql: ${TABLE}."NUMBER_LINE" ;;
  }
  dimension: number_offset_gl_account {
    type: string
    sql: ${TABLE}."NUMBER_OFFSET_GL_ACCOUNT" ;;
  }
  dimension: number_order {
    type: string
    sql: ${TABLE}."NUMBER_ORDER" ;;
  }
  dimension: number_pr_entry_offset_account {
    type: string
    sql: ${TABLE}."NUMBER_PR_ENTRY_OFFSET_ACCOUNT" ;;
  }
  dimension: number_serial {
    type: string
    sql: ${TABLE}."NUMBER_SERIAL" ;;
  }
  dimension: number_ud_esadmin_invoice {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESADMIN_INVOICE" ;;
  }
  dimension: number_ud_estrack_work_order {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESTRACK_WORK_ORDER" ;;
  }
  dimension: offset_gl {
    type: string
    sql: ${TABLE}."OFFSET_GL" ;;
  }
  dimension: percentage_retainage {
    type: string
    sql: ${TABLE}."PERCENTAGE_RETAINAGE" ;;
  }
  dimension: pk_ap_line_id {
    type: number
    sql: ${TABLE}."PK_AP_LINE_ID" ;;
  }
  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
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
  dimension: title_account {
    type: string
    sql: ${TABLE}."TITLE_ACCOUNT" ;;
  }
  dimension: title_offset_gl_account {
    type: string
    sql: ${TABLE}."TITLE_OFFSET_GL_ACCOUNT" ;;
  }
  dimension: type_form_1099 {
    type: string
    sql: ${TABLE}."TYPE_FORM_1099" ;;
  }
  dimension: type_record {
    type: string
    sql: ${TABLE}."TYPE_RECORD" ;;
  }
  dimension: version_vendor_account_no_key {
    type: string
    sql: ${TABLE}."VERSION_VENDOR_ACCOUNT_NO_KEY" ;;
  }
  measure: count {
    type: count
  }
}
