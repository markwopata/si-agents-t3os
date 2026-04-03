view: integrations_vic_costcapture_sandbox__po_line_check {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_COSTCAPTURE_SANDBOX__PO_LINE_CHECK" ;;

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: is_archived_line {
    type: yesno
    sql: ${TABLE}."IS_ARCHIVED_LINE" ;;
  }
  dimension: is_invalid_ppu {
    type: yesno
    sql: ${TABLE}."IS_INVALID_PPU" ;;
  }
  dimension: is_invalid_qty_ordered {
    type: yesno
    sql: ${TABLE}."IS_INVALID_QTY_ORDERED" ;;
  }
  dimension: is_line_alerted {
    type: yesno
    sql: ${TABLE}."IS_LINE_ALERTED" ;;
  }
  dimension: is_line_blocked {
    type: yesno
    sql: ${TABLE}."IS_LINE_BLOCKED" ;;
  }
  dimension: is_null_po_number {
    type: yesno
    sql: ${TABLE}."IS_NULL_PO_NUMBER" ;;
  }
  dimension: is_null_sage_item_id {
    type: yesno
    sql: ${TABLE}."IS_NULL_SAGE_ITEM_ID" ;;
  }
  dimension: is_qty_rejected_likely_wrong {
    type: yesno
    sql: ${TABLE}."IS_QTY_REJECTED_LIKELY_WRONG" ;;
  }
  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }
  dimension: pk_po_line_id {
    type: string
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  measure: count {
    type: count
  }
}
