view: intacct_sandbox__gl_resolve {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__GL_RESOLVE" ;;

  dimension: amount_resolve {
    type: number
    sql: ${TABLE}."AMOUNT_RESOLVE" ;;
  }
  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
  }
  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }
  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_doc_entry_id {
    type: number
    sql: ${TABLE}."FK_DOC_ENTRY_ID" ;;
  }
  dimension: fk_doc_header_id {
    type: number
    sql: ${TABLE}."FK_DOC_HEADER_ID" ;;
  }
  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_pr_entry_id {
    type: number
    sql: ${TABLE}."FK_PR_ENTRY_ID" ;;
  }
  dimension: fk_pr_record_id {
    type: number
    sql: ${TABLE}."FK_PR_RECORD_ID" ;;
  }
  dimension: gle_account_number {
    type: string
    sql: ${TABLE}."GLE_ACCOUNT_NUMBER" ;;
  }
  dimension: gle_amount_gl {
    type: number
    sql: ${TABLE}."GLE_AMOUNT_GL" ;;
  }
  dimension: gle_amount_signed {
    type: number
    sql: ${TABLE}."GLE_AMOUNT_SIGNED" ;;
  }
  dimension: gle_batch_number {
    type: string
    sql: ${TABLE}."GLE_BATCH_NUMBER" ;;
  }
  dimension: gle_batch_title {
    type: string
    sql: ${TABLE}."GLE_BATCH_TITLE" ;;
  }
  dimension: gle_id_department {
    type: string
    sql: ${TABLE}."GLE_ID_DEPARTMENT" ;;
  }
  dimension: gle_id_location {
    type: string
    sql: ${TABLE}."GLE_ID_LOCATION" ;;
  }
  dimension: gle_line_number {
    type: number
    sql: ${TABLE}."GLE_LINE_NUMBER" ;;
  }
  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }
  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }
  dimension: name_doc_created_from {
    type: string
    sql: ${TABLE}."NAME_DOC_CREATED_FROM" ;;
  }
  dimension: name_document {
    type: string
    sql: ${TABLE}."NAME_DOCUMENT" ;;
  }
  dimension: name_line_item {
    type: string
    sql: ${TABLE}."NAME_LINE_ITEM" ;;
  }
  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }
  dimension: name_t3_po_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PO_CREATED_BY" ;;
  }
  dimension: pk_gl_resolve_id {
    type: string
    sql: ${TABLE}."PK_GL_RESOLVE_ID" ;;
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
  dimension: type_item {
    type: string
    sql: ${TABLE}."TYPE_ITEM" ;;
  }
  dimension: url_invoice {
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
  }
  measure: count {
    type: count
  }
}
