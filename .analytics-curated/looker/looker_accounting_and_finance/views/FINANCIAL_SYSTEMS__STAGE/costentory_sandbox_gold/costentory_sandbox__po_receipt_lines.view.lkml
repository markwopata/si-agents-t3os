view: costentory_sandbox__po_receipt_lines {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__PO_RECEIPT_LINES" ;;

  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }
  dimension: email_creator {
    type: string
    sql: ${TABLE}."EMAIL_CREATOR" ;;
  }
  dimension: email_modifier {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIER" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_item_id {
    type: string
    sql: ${TABLE}."FK_ITEM_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_po_line_id {
    type: string
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
  }
  dimension: fk_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_PO_RECEIPT_HEADER_ID" ;;
  }
  dimension: name_creator {
    type: string
    sql: ${TABLE}."NAME_CREATOR" ;;
  }
  dimension: name_item_type {
    type: string
    sql: ${TABLE}."NAME_ITEM_TYPE" ;;
  }
  dimension: name_modifier {
    type: string
    sql: ${TABLE}."NAME_MODIFIER" ;;
  }
  dimension: name_part {
    type: string
    sql: ${TABLE}."NAME_PART" ;;
  }
  dimension: name_part_type {
    type: string
    sql: ${TABLE}."NAME_PART_TYPE" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: pk_po_receipt_line_id {
    type: string
    sql: ${TABLE}."PK_PO_RECEIPT_LINE_ID" ;;
    primary_key: yes
  }
  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }
  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }
  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_CREATED" AS TIMESTAMP_NTZ) ;;
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
  measure: count {
    type: count
  }
}
