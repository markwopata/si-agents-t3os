view: vic_sandbox__po_line_invoice_items_matched {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__PO_LINE_INVOICE_ITEMS_MATCHED" ;;

  dimension: amount_matched {
    type: number
    sql: ${TABLE}."AMOUNT_MATCHED" ;;
  }
  dimension: fk_invoice_item_id {
    type: string
    sql: ${TABLE}."FK_INVOICE_ITEM_ID" ;;
  }
  dimension: fk_po_line_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_PO_LINE_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_purchase_order_item_id {
    type: string
    sql: ${TABLE}."FK_PURCHASE_ORDER_ITEM_ID" ;;
  }
  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }
  dimension: fk_vic_po_line_id {
    type: string
    sql: ${TABLE}."FK_VIC_PO_LINE_ID" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: pk_extract_hash_id {
    type: number
    sql: ${TABLE}."PK_EXTRACT_HASH_ID" ;;
  }
  dimension: qty_matched {
    type: number
    sql: ${TABLE}."QTY_MATCHED" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
}
