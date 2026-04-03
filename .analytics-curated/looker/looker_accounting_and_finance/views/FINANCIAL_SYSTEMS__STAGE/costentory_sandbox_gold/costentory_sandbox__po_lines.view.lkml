view: costentory_sandbox__po_lines {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY_SANDBOX__PO_LINES" ;;

  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }
  dimension: amount_accepted {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
  }
  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
  }
  dimension: amount_rejected {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }
  dimension: email_modified_by {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIED_BY" ;;
  }
  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_deliver_to_id {
    type: number
    sql: ${TABLE}."FK_DELIVER_TO_ID" ;;
  }
  dimension: fk_item_id {
    type: string
    sql: ${TABLE}."FK_ITEM_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_parent_store_id {
    type: number
    sql: ${TABLE}."FK_PARENT_STORE_ID" ;;
  }
  dimension: fk_part_id {
    type: number
    sql: ${TABLE}."FK_PART_ID" ;;
  }
  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: fk_provider_id {
    type: number
    sql: ${TABLE}."FK_PROVIDER_ID" ;;
  }
  dimension: fk_requesting_branch_id {
    type: number
    sql: ${TABLE}."FK_REQUESTING_BRANCH_ID" ;;
  }
  dimension: fk_store_id {
    type: number
    sql: ${TABLE}."FK_STORE_ID" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }
  dimension: name_deliver_to_branch {
    type: string
    sql: ${TABLE}."NAME_DELIVER_TO_BRANCH" ;;
  }
  dimension: name_item_type {
    type: string
    sql: ${TABLE}."NAME_ITEM_TYPE" ;;
  }
  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }
  dimension: name_part {
    type: string
    sql: ${TABLE}."NAME_PART" ;;
  }
  dimension: name_part_type {
    type: string
    sql: ${TABLE}."NAME_PART_TYPE" ;;
  }
  dimension: name_provider {
    type: string
    sql: ${TABLE}."NAME_PROVIDER" ;;
  }
  dimension: name_requesting_branch {
    type: string
    sql: ${TABLE}."NAME_REQUESTING_BRANCH" ;;
  }
  dimension: name_store {
    type: string
    sql: ${TABLE}."NAME_STORE" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
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
  dimension: ppu {
    type: number
    sql: ${TABLE}."PPU" ;;
  }
  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }
  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
  }
  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }
  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
  }
  dimension: sage_item_id {
    type: string
    sql: ${TABLE}."SAGE_ITEM_ID" ;;
  }
  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }
  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_LOADED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_po_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_PO_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_po_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_CREATED" ;;
  }
  dimension_group: timestamp_po_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_MODIFIED" ;;
  }
  measure: count {
    type: count
  }
}
