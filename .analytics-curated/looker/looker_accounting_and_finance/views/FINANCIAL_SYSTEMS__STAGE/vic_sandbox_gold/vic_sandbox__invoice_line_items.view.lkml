view: vic_sandbox__invoice_line_items {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__INVOICE_LINE_ITEMS" ;;

  dimension: amount_freight {
    type: number
    sql: ${TABLE}."AMOUNT_FREIGHT" ;;
  }
  dimension: amount_item {
    type: number
    sql: ${TABLE}."AMOUNT_ITEM" ;;
  }
  dimension: amount_line_total {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_TOTAL" ;;
  }
  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
  }
  dimension: amount_sum {
    type: number
    sql: ${TABLE}."AMOUNT_SUM" ;;
  }
  dimension: amount_tax {
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
  }
  dimension: amount_vat {
    type: number
    sql: ${TABLE}."AMOUNT_VAT" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: dimensions {
    type: string
    sql: ${TABLE}."DIMENSIONS" ;;
  }
  dimension: fk_dimensions_external_ids {
    type: string
    sql: ${TABLE}."FK_DIMENSIONS_EXTERNAL_IDS" ;;
  }
  dimension: fk_dimensions_internal_ids {
    type: string
    sql: ${TABLE}."FK_DIMENSIONS_INTERNAL_IDS" ;;
  }
  dimension: fk_invoice_line_item_id {
    type: number
    sql: ${TABLE}."FK_INVOICE_LINE_ITEM_ID" ;;
  }
  dimension: fk_sage_cost_account_id {
    type: string
    sql: ${TABLE}."FK_SAGE_COST_ACCOUNT_ID" ;;
  }
  dimension: fk_vic_cost_account_id {
    type: string
    sql: ${TABLE}."FK_VIC_COST_ACCOUNT_ID" ;;
  }
  dimension: is_billable {
    type: yesno
    sql: ${TABLE}."IS_BILLABLE" ;;
  }
  dimension: line_item_fields_1 {
    type: string
    sql: ${TABLE}."LINE_ITEM_FIELDS_1" ;;
  }
  dimension: line_item_fields_2 {
    type: string
    sql: ${TABLE}."LINE_ITEM_FIELDS_2" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: line_type {
    type: string
    sql: ${TABLE}."LINE_TYPE" ;;
  }
  dimension: name_cost_account {
    type: string
    sql: ${TABLE}."NAME_COST_ACCOUNT" ;;
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
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: qty_invoiced {
    type: string
    sql: ${TABLE}."QTY_INVOICED" ;;
  }
  dimension: tax_code {
    type: string
    sql: ${TABLE}."TAX_CODE" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: unit_price {
    type: string
    sql: ${TABLE}."UNIT_PRICE" ;;
  }
  dimension: vat_amount {
    type: string
    sql: ${TABLE}."VAT_AMOUNT" ;;
  }
  dimension: vat_code {
    type: string
    sql: ${TABLE}."VAT_CODE" ;;
  }
  dimension: vat_external_id {
    type: string
    sql: ${TABLE}."VAT_EXTERNAL_ID" ;;
  }
  dimension: vat_internal_id {
    type: string
    sql: ${TABLE}."VAT_INTERNAL_ID" ;;
  }
  dimension: vat_rate {
    type: string
    sql: ${TABLE}."VAT_RATE" ;;
  }
  measure: count {
    type: count
  }
}
