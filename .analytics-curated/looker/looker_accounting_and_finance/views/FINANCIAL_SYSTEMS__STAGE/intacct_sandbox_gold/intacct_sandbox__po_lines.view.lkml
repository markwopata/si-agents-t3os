view: intacct_sandbox__po_lines {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__PO_LINES" ;;

  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
  }
  dimension: amount_total_converted {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_CONVERTED" ;;
  }
  dimension: amount_total_remaining {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_REMAINING" ;;
  }
  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
  }
  dimension: amount_trx_value {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_VALUE" ;;
  }
  dimension: amount_ui_ppu {
    type: number
    sql: ${TABLE}."AMOUNT_UI_PPU" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_promised {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PROMISED" ;;
  }
  dimension: description_item {
    type: string
    sql: ${TABLE}."DESCRIPTION_ITEM" ;;
  }
  dimension: esadmin_invoice_number {
    type: string
    sql: ${TABLE}."ESADMIN_INVOICE_NUMBER" ;;
  }
  dimension: esadmin_workorder_number {
    type: string
    sql: ${TABLE}."ESADMIN_WORKORDER_NUMBER" ;;
  }
  dimension: fk_asset_id {
    type: string
    sql: ${TABLE}."FK_ASSET_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_expense_line_id {
    type: string
    sql: ${TABLE}."FK_EXPENSE_LINE_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_gl_dim_asset_id {
    type: string
    sql: ${TABLE}."FK_GL_DIM_ASSET_ID" ;;
  }
  dimension: fk_gl_transaction_id {
    type: string
    sql: ${TABLE}."FK_GL_TRANSACTION_ID" ;;
  }
  dimension: fk_item_gl_group_id {
    type: number
    sql: ${TABLE}."FK_ITEM_GL_GROUP_ID" ;;
  }
  dimension: fk_loan_id {
    type: string
    sql: ${TABLE}."FK_LOAN_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_original_document_id {
    type: number
    sql: ${TABLE}."FK_ORIGINAL_DOCUMENT_ID" ;;
  }
  dimension: fk_original_document_line_id {
    type: number
    sql: ${TABLE}."FK_ORIGINAL_DOCUMENT_LINE_ID" ;;
  }
  dimension: fk_source_document_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_DOCUMENT_ID" ;;
  }
  dimension: fk_source_document_line_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_DOCUMENT_LINE_ID" ;;
  }
  dimension: fk_t3_po_line_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_LINE_ID" ;;
  }
  dimension: form_1099_box {
    type: string
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }
  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
  }
  dimension: id_department {
    type: number
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }
  dimension: id_entity {
    type: string
    sql: ${TABLE}."ID_ENTITY" ;;
  }
  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }
  dimension: id_source_document {
    type: string
    sql: ${TABLE}."ID_SOURCE_DOCUMENT" ;;
  }
  dimension: id_source_document_line {
    type: string
    sql: ${TABLE}."ID_SOURCE_DOCUMENT_LINE" ;;
  }
  dimension: is_form_1099 {
    type: yesno
    sql: ${TABLE}."IS_FORM_1099" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }
  dimension: name_entity {
    type: string
    sql: ${TABLE}."NAME_ENTITY" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }
  dimension: pk_po_line_id {
    type: number
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
  }
  dimension: ppu {
    type: number
    sql: ${TABLE}."PPU" ;;
  }
  dimension: ppu_converted {
    type: number
    sql: ${TABLE}."PPU_CONVERTED" ;;
  }
  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }
  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
  }
  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
  }
  dimension: qty_ui {
    type: number
    sql: ${TABLE}."QTY_UI" ;;
  }
  dimension: related_document_line_number {
    type: string
    sql: ${TABLE}."RELATED_DOCUMENT_LINE_NUMBER" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: status_line {
    type: string
    sql: ${TABLE}."STATUS_LINE" ;;
  }
  dimension: t3_part_details {
    type: string
    sql: ${TABLE}."T3_PART_DETAILS" ;;
  }
  dimension: t3_part_number {
    type: string
    sql: ${TABLE}."T3_PART_NUMBER" ;;
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
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  measure: count {
    type: count
  }
}
