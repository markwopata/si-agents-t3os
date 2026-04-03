view: costentory__po_lines {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__PO_LINES" ;;

  dimension: pk_po_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: name_item_type {
    type: string
    sql: ${TABLE}."NAME_ITEM_TYPE" ;;
  }

  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }

  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
    group_label: "Quantities"
  }

  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
    group_label: "Quantities"
  }

  dimension: ppu {
    type: number
    sql: ${TABLE}."PPU" ;;
  }

  dimension: amount_ordered {
    type: number
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_rejected {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_accepted {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: name_provider {
    type: string
    sql: ${TABLE}."NAME_PROVIDER" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: sage_item_id {
    type: string
    sql: ${TABLE}."SAGE_ITEM_ID" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: name_part {
    type: string
    sql: ${TABLE}."NAME_PART" ;;
  }

  dimension: name_part_type {
    type: string
    sql: ${TABLE}."NAME_PART_TYPE" ;;
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
  }

  dimension: name_effective_branch {
    type: string
    sql: ${TABLE}."NAME_EFFECTIVE_BRANCH" ;;
  }

  dimension: name_requesting_branch {
    type: string
    sql: ${TABLE}."NAME_REQUESTING_BRANCH" ;;
  }

  dimension: name_deliver_to_branch {
    type: string
    sql: ${TABLE}."NAME_DELIVER_TO_BRANCH" ;;
  }

  dimension: name_store {
    type: string
    sql: ${TABLE}."NAME_STORE" ;;
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_item_id {
    type: string
    sql: ${TABLE}."FK_ITEM_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_part_id {
    type: number
    sql: ${TABLE}."FK_PART_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_provider_id {
    type: number
    sql: ${TABLE}."FK_PROVIDER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_requesting_branch_id {
    type: number
    sql: ${TABLE}."FK_REQUESTING_BRANCH_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_deliver_to_id {
    type: number
    sql: ${TABLE}."FK_DELIVER_TO_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_store_id {
    type: number
    sql: ${TABLE}."FK_STORE_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_parent_store_id {
    type: number
    sql: ${TABLE}."FK_PARENT_STORE_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension_group: timestamp_po_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_CREATED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_po_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_MODIFIED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_po_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_PO_ARCHIVED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_ARCHIVED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
    group_label: "Timestamps"
  }

  set: detail {
    fields: [
      pk_po_line_id,
      po_number,
      name_item_type,
      allocation_type,
      qty_ordered,
      qty_rejected,
      qty_accepted,
      qty_received,
      ppu,
      amount_ordered,
      amount_received,
      amount_rejected,
      amount_accepted,
      search,
      description,
      memo,
      name_provider,
      part_number,
      sage_item_id,
      name_item,
      name_part,
      name_part_type,
      id_effective_branch,
      name_effective_branch,
      name_requesting_branch,
      name_deliver_to_branch,
      name_store,
      fk_po_header_id,
      fk_item_id,
      fk_part_id,
      fk_provider_id,
      fk_company_id,
      fk_requesting_branch_id,
      fk_deliver_to_id,
      fk_store_id,
      fk_parent_store_id,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      timestamp_po_created_date,
      timestamp_po_modified_date,
      timestamp_po_archived_date,
      timestamp_archived_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_ordered {
    type: sum
    sql: ${TABLE}."AMOUNT_ORDERED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_rejected {
    type: sum
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_accepted {
    type: sum
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_ordered {
    type: average
    sql: ${TABLE}."QTY_ORDERED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_rejected {
    type: average
    sql: ${TABLE}."QTY_REJECTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_accepted {
    type: average
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_received {
    type: average
    sql: ${TABLE}."QTY_RECEIVED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
