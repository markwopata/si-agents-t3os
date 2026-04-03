view: costentory__po_receipt_lines {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__PO_RECEIPT_LINES" ;;

  dimension: pk_po_receipt_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PO_RECEIPT_LINE_ID" ;;
  }

  dimension: fk_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_PO_RECEIPT_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_po_line_id {
    type: string
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: sage_item_id {
    type: string
    sql: ${TABLE}."SAGE_ITEM_ID" ;;
  }

  dimension: name_item_type {
    type: string
    sql: ${TABLE}."NAME_ITEM_TYPE" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: name_part {
    type: string
    sql: ${TABLE}."NAME_PART" ;;
  }

  dimension: name_part_type {
    type: string
    sql: ${TABLE}."NAME_PART_TYPE" ;;
  }

  dimension: qty_accepted {
    type: number
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_rejected {
    type: number
    sql: ${TABLE}."QTY_REJECTED" ;;
    group_label: "Quantities"
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
    group_label: "Quantities"
  }

  dimension: amount_accepted {
    type: number
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_rejected {
    type: number
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
  }

  dimension: name_effective_branch {
    type: string
    sql: ${TABLE}."NAME_EFFECTIVE_BRANCH" ;;
  }

  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }

  dimension: name_creator {
    type: string
    sql: ${TABLE}."NAME_CREATOR" ;;
  }

  dimension: email_creator {
    type: string
    sql: ${TABLE}."EMAIL_CREATOR" ;;
  }

  dimension: name_modifier {
    type: string
    sql: ${TABLE}."NAME_MODIFIER" ;;
  }

  dimension: email_modifier {
    type: string
    sql: ${TABLE}."EMAIL_MODIFIER" ;;
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

  dimension: fk_part_id {
    type: number
    sql: ${TABLE}."FK_PART_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_item_id {
    type: string
    sql: ${TABLE}."FK_ITEM_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_company_id {
    type: number
    sql: ${TABLE}."FK_COMPANY_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
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
      pk_po_receipt_line_id,
      fk_po_receipt_header_id,
      fk_po_header_id,
      fk_po_line_id,
      po_number,
      sage_item_id,
      name_item_type,
      part_number,
      name_part,
      name_part_type,
      qty_accepted,
      qty_rejected,
      qty_received,
      amount_accepted,
      amount_rejected,
      amount_received,
      ppu_receipt,
      id_effective_branch,
      name_effective_branch,
      allocation_type,
      name_creator,
      email_creator,
      name_modifier,
      email_modifier,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_part_id,
      fk_item_id,
      fk_company_id,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_archived_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_accepted {
    type: sum
    sql: ${TABLE}."AMOUNT_ACCEPTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_rejected {
    type: sum
    sql: ${TABLE}."AMOUNT_REJECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_accepted {
    type: average
    sql: ${TABLE}."QTY_ACCEPTED" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }

  measure: avg_qty_rejected {
    type: average
    sql: ${TABLE}."QTY_REJECTED" ;;
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
