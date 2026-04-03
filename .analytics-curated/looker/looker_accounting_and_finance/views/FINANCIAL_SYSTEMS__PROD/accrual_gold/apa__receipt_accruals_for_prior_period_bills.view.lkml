view: apa__receipt_accruals_for_prior_period_bills {
  sql_table_name: "ACCRUAL_GOLD"."APA__RECEIPT_ACCRUALS_FOR_PRIOR_PERIOD_BILLS" ;;

  dimension: amount_gl_entry {
    type: number
    sql: ${TABLE}."AMOUNT_GL_ENTRY" ;;
  }
  dimension: amount_signed_gl_entry {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED_GL_ENTRY" ;;
  }
  dimension: amount_signed_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED_TRANSACTION" ;;
  }
  dimension: amount_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_TRANSACTION" ;;
  }
  dimension_group: date_earliest_bill_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_BILL_POSTED" ;;
  }
  dimension_group: date_earliest_receipt_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_EARLIEST_RECEIPT_POSTED" ;;
  }
  dimension_group: date_gl_batch_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_POSTED" ;;
  }
  dimension_group: date_gl_batch_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_REVERSED_FROM" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }
  dimension: fk_gl_batch_id {
    type: number
    sql: ${TABLE}."FK_GL_BATCH_ID" ;;
  }
  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
  }
  dimension: fk_gl_resolve_id {
    type: string
    sql: ${TABLE}."FK_GL_RESOLVE_ID" ;;
  }
  dimension: fk_origin_header_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_HEADER_ID" ;;
  }
  dimension: fk_origin_line_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_LINE_ID" ;;
  }
  dimension: fk_posting_header_id {
    type: string
    sql: ${TABLE}."FK_POSTING_HEADER_ID" ;;
  }
  dimension: fk_posting_line_id {
    type: string
    sql: ${TABLE}."FK_POSTING_LINE_ID" ;;
  }
  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }
  dimension: id_expense_line {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }
  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }
  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }
  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }
  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }
  dimension: name_account_ultimate {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT_ULTIMATE" ;;
  }
  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }
  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }
  dimension: name_gl_batch_creator {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_CREATOR" ;;
  }
  dimension: name_gl_batch_modifier {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_MODIFIER" ;;
  }
  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }
  dimension: number_account_ultimate {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT_ULTIMATE" ;;
  }
  dimension: number_batch {
    type: number
    sql: ${TABLE}."NUMBER_BATCH" ;;
  }
  dimension: origin_document {
    type: string
    sql: ${TABLE}."ORIGIN_DOCUMENT" ;;
  }
  dimension: pk_gl_subledger_id {
    type: string
    sql: ${TABLE}."PK_GL_SUBLEDGER_ID" ;;
  }
  dimension: posting_document {
    type: string
    sql: ${TABLE}."POSTING_DOCUMENT" ;;
  }
  dimension: reference_batch {
    type: string
    sql: ${TABLE}."REFERENCE_BATCH" ;;
  }
  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }
  dimension: state_origin_document {
    type: string
    sql: ${TABLE}."STATE_ORIGIN_DOCUMENT" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_DDS_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }
  dimension: type_gl_transaction {
    type: string
    sql: ${TABLE}."TYPE_GL_TRANSACTION" ;;
  }
  dimension: type_transaction {
    type: number
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }
  dimension: url_gl_batch {
    type: string
    sql: ${TABLE}."URL_GL_BATCH" ;;
  }
  dimension: url_origin_document {
    type: string
    sql: ${TABLE}."URL_ORIGIN_DOCUMENT" ;;
  }
  dimension: url_posting_document {
    type: string
    sql: ${TABLE}."URL_POSTING_DOCUMENT" ;;
  }
  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  dimension: url_vic_invoice {
    type: string
    sql: ${TABLE}."URL_VIC_INVOICE" ;;
  }
  dimension: url_vic_po {
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
  }
  measure: count {
    type: count
  }
}
