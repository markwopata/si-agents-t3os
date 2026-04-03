view: vic_sandbox__invoice_lines {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__INVOICE_LINES" ;;

  dimension: amount_line {
    type: number
    sql: ${TABLE}."AMOUNT_LINE" ;;
  }
  dimension: amount_line_tax {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_TAX" ;;
  }
  dimension: dimensions {
    type: string
    sql: ${TABLE}."DIMENSIONS" ;;
  }
  dimension: fk_cost_account_external_id {
    type: string
    sql: ${TABLE}."FK_COST_ACCOUNT_EXTERNAL_ID" ;;
  }
  dimension: fk_cost_account_internal_id {
    type: string
    sql: ${TABLE}."FK_COST_ACCOUNT_INTERNAL_ID" ;;
  }
  dimension: fk_invoice_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_INVOICE_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_sage_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_INVOICE_HEADER_ID" ;;
  }
  dimension: fk_vic_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_VIC_INVOICE_HEADER_ID" ;;
  }
  dimension: is_line_billable {
    type: yesno
    sql: ${TABLE}."IS_LINE_BILLABLE" ;;
  }
  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
  }
  dimension: line_item_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_TOTAL" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: line_type {
    type: string
    sql: ${TABLE}."LINE_TYPE" ;;
  }
  dimension: line_unit_price {
    type: number
    sql: ${TABLE}."LINE_UNIT_PRICE" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: pk_extract_hash_id {
    type: number
    sql: ${TABLE}."PK_EXTRACT_HASH_ID" ;;
  }
  dimension: po_items_matched {
    type: string
    sql: ${TABLE}."PO_ITEMS_MATCHED" ;;
  }
  dimension: qty_line {
    type: number
    sql: ${TABLE}."QTY_LINE" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
