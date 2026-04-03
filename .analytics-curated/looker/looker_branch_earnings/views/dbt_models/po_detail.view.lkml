view: po_detail {
  sql_table_name: "ANALYTICS"."INTACCT_MODELS"."PO_DETAIL" ;;
  drill_fields: [pk_po_detail_id]

  dimension: pk_po_detail_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_DETAIL_ID" ;;
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created_header {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED_HEADER" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated_header {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED_HEADER" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated_line {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED_LINE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }
  dimension: document_name {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
  }
  dimension: document_number {
    type: string
    sql: ${TABLE}."DOCUMENT_NUMBER" ;;
  }
  dimension: document_status {
    type: string
    sql: ${TABLE}."DOCUMENT_STATUS" ;;
  }
  dimension: document_type {
    type: string
    sql: ${TABLE}."DOCUMENT_TYPE" ;;
  }
  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }
  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }
  dimension: expense_type {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE" ;;
  }
  dimension: extended_amount {
    type: number
    sql: ${TABLE}."EXTENDED_AMOUNT" ;;
  }
  dimension: extended_entity_name {
    type: string
    sql: ${TABLE}."EXTENDED_ENTITY_NAME" ;;
  }
  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
  }
  dimension: fk_expense_type_id {
    type: number
    sql: ${TABLE}."FK_EXPENSE_TYPE_ID" ;;
  }
  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: fk_po_line_id {
    type: number
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
  }
  dimension: fk_sage_po_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_SAGE_PO_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }
  dimension: fk_t3_po_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_T3_PO_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_t3_pr_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_T3_PR_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_t3_purchase_order_id {
    type: string
    sql: ${TABLE}."FK_T3_PURCHASE_ORDER_ID" ;;
  }
  dimension: fk_t3_purchase_order_receiver_item_id {
    type: string
    sql: ${TABLE}."FK_T3_PURCHASE_ORDER_RECEIVER_ITEM_ID" ;;
  }
  dimension_group: gl {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."GL_DATE" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_blanket_po {
    type: yesno
    sql: ${TABLE}."IS_BLANKET_PO" ;;
  }
  dimension: item_description {
    type: string
    sql: ${TABLE}."ITEM_DESCRIPTION" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: item_type {
    type: string
    sql: ${TABLE}."ITEM_TYPE" ;;
  }
  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: line_offset_account {
    type: string
    sql: ${TABLE}."LINE_OFFSET_ACCOUNT" ;;
  }
  dimension: line_posting_account {
    type: string
    sql: ${TABLE}."LINE_POSTING_ACCOUNT" ;;
  }
  dimension: line_status {
    type: string
    sql: ${TABLE}."LINE_STATUS" ;;
  }
  dimension: po_message {
    type: string
    sql: ${TABLE}."PO_MESSAGE" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: po_state {
    type: string
    sql: ${TABLE}."PO_STATE" ;;
  }
  dimension: purchase_order_line_memo {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_LINE_MEMO" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: quantity_converted {
    type: number
    sql: ${TABLE}."QUANTITY_CONVERTED" ;;
  }
  dimension: quantity_remaining {
    type: number
    sql: ${TABLE}."QUANTITY_REMAINING" ;;
  }
  dimension: receipt_number {
    type: string
    sql: ${TABLE}."RECEIPT_NUMBER" ;;
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: sage_po_created_by_name {
    type: string
    sql: ${TABLE}."SAGE_PO_CREATED_BY_NAME" ;;
  }
  dimension: source_document_name {
    type: string
    sql: ${TABLE}."SOURCE_DOCUMENT_NAME" ;;
  }
  dimension: t3_po_created_by_name {
    type: string
    sql: ${TABLE}."T3_PO_CREATED_BY_NAME" ;;
  }
  dimension: t3_pr_created_by_name {
    type: string
    sql: ${TABLE}."T3_PR_CREATED_BY_NAME" ;;
  }
  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  dimension: unit_price {
    type: number
    sql: ${TABLE}."UNIT_PRICE" ;;
  }
  dimension: url_concur {
    type: string
    sql: ${TABLE}."URL_CONCUR" ;;
  }
  dimension: url_sage {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
  }
  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_invoice_number {
    type: string
    sql: ${TABLE}."VENDOR_INVOICE_NUMBER" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: quantity_agg {
    label: "Total Quantity"
    type: sum
    sql: ${quantity} ;;
  }

  measure: unit_price_agg {
    label: "Total Unit Price"
    type: sum
    sql: ${unit_price} ;;
    value_format_name: usd
  }

  measure: extended_amount_agg {
    label: "Total Amount"
    type: sum
    sql: ${extended_amount} ;;
    value_format_name: usd
  }

  dimension: open_po_flag {
    type: yesno
    sql: case when ${po_state} = 'Pending'
              then TRUE
              else FALSE
              end;;
  }

  measure: open_po_amount {
    label: "Total Open PO Amount"
    type: sum
    sql: ${extended_amount} ;;
    value_format_name: usd
    filters: [open_po_flag: "yes"]
  }

  measure: open_po_count {
    label: "Total Number of Open PO's"
    type: count_distinct
    sql: ${po_number} ;;
    filters: [open_po_flag: "yes"]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  pk_po_detail_id,
  t3_po_created_by_name,
  document_name,
  vendor_name,
  t3_pr_created_by_name,
  department_name,
  extended_entity_name,
  source_document_name,
  entity_name,
  sage_po_created_by_name,
  account_name
  ]
  }

}
