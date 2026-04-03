view: intacct__po_lines {
  sql_table_name: "INTACCT_GOLD"."INTACCT__PO_LINES" ;;

  dimension: pk_po_line_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_po_header_id {
    type: number
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: name_document {
    type: string
    sql: ${TABLE}."NAME_DOCUMENT" ;;
  }

  dimension: type_document {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT" ;;
  }

  dimension: name_source_document {
    type: string
    sql: ${TABLE}."NAME_SOURCE_DOCUMENT" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: status_line {
    type: string
    sql: ${TABLE}."STATUS_LINE" ;;
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: type_item {
    type: string
    sql: ${TABLE}."TYPE_ITEM" ;;
  }

  dimension: description_item {
    type: string
    sql: ${TABLE}."DESCRIPTION_ITEM" ;;
  }

  dimension: id_expense_line {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }

  dimension: category_expense {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE" ;;
  }

  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }

  dimension: qty_requested {
    type: number
    sql: ${TABLE}."QTY_REQUESTED" ;;
  }

  dimension: qty_converted {
    type: number
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }

  dimension: qty_remaining {
    type: number
    sql: ${TABLE}."QTY_REMAINING" ;;
  }

  dimension: qty_ui {
    type: number
    sql: ${TABLE}."QTY_UI" ;;
  }

  dimension: ppu {
    type: number
    sql: ${TABLE}."PPU" ;;
  }

  dimension: ppu_converted {
    type: number
    sql: ${TABLE}."PPU_CONVERTED" ;;
  }

  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
  }

  dimension: amount_trx_value {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_VALUE" ;;
    value_format_name: usd
  }

  dimension: amount_ui_ppu {
    type: number
    sql: ${TABLE}."AMOUNT_UI_PPU" ;;
    value_format_name: usd
  }

  dimension: t3_part_details {
    type: string
    sql: ${TABLE}."T3_PART_DETAILS" ;;
  }

  dimension: t3_part_number {
    type: string
    sql: ${TABLE}."T3_PART_NUMBER" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: related_document_line_number {
    type: string
    sql: ${TABLE}."RELATED_DOCUMENT_LINE_NUMBER" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: id_entity {
    type: string
    sql: ${TABLE}."ID_ENTITY" ;;
  }

  dimension: name_entity {
    type: string
    sql: ${TABLE}."NAME_ENTITY" ;;
  }

  dimension: fk_department_id {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: is_form_1099 {
    type: yesno
    sql: ${TABLE}."IS_FORM_1099" ;;
    html:
      {% if value == 'Yes' %}
        <span style="background-color:yellow; color:black; padding:3px;">Yes</span>
      {% else %}
        No
      {% endif %}
    ;;
  }

  dimension: form_1099_box {
    type: string
    sql: ${TABLE}."FORM_1099_BOX" ;;
  }

  dimension: form_1099_type {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE" ;;
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

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_source_po_header_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_grandparent_po_header_id {
    type: number
    sql: ${TABLE}."FK_GRANDPARENT_PO_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_source_document_line_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_DOCUMENT_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_grandparent_document_line_id {
    type: number
    sql: ${TABLE}."FK_GRANDPARENT_DOCUMENT_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_t3_po_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_T3_PO_RECEIPT_LINE_ID" ;;
  }

  dimension: fk_asset_id {
    type: string
    sql: ${TABLE}."FK_ASSET_ID" ;;
  }

  dimension: fk_gl_dim_asset_id {
    type: string
    sql: ${TABLE}."FK_GL_DIM_ASSET_ID" ;;
  }

  dimension: fk_gl_transaction_id {
    type: string
    sql: ${TABLE}."FK_GL_TRANSACTION_ID" ;;
  }

  dimension: fk_loan_id {
    type: string
    sql: ${TABLE}."FK_LOAN_ID" ;;
  }

  dimension: fk_item_gl_group_id {
    type: number
    sql: ${TABLE}."FK_ITEM_GL_GROUP_ID" ;;
    value_format_name: id
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
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

  set: detail {
    fields: [
      pk_po_line_id,
      fk_po_header_id,
      name_document,
      type_document,
      name_source_document,
      line_number,
      status_line,
      number_account,
      name_account,
      id_item,
      name_item,
      type_item,
      description_item,
      id_expense_line,
      name_expense_line,
      category_expense,
      unit_of_measure,
      qty_requested,
      qty_converted,
      qty_remaining,
      qty_ui,
      ppu,
      ppu_converted,
      amount_total,
      amount_trx,
      amount_trx_value,
      amount_ui_ppu,
      t3_part_details,
      t3_part_number,
      memo,
      related_document_line_number,
      serial_number,
      id_entity,
      name_entity,
      fk_department_id,
      name_department,
      is_form_1099,
      form_1099_box,
      form_1099_type,
      date_created_date,
      date_promised_date,
      name_created_by_user,
      name_modified_by_user,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_source_po_header_id,
      fk_grandparent_po_header_id,
      fk_source_document_line_id,
      fk_grandparent_document_line_id,
      fk_t3_po_receipt_line_id,
      fk_asset_id,
      fk_gl_dim_asset_id,
      fk_gl_transaction_id,
      fk_loan_id,
      fk_item_gl_group_id,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_dds_loaded_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_total {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_value {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_VALUE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_ui_ppu {
    type: sum
    sql: ${TABLE}."AMOUNT_UI_PPU" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
