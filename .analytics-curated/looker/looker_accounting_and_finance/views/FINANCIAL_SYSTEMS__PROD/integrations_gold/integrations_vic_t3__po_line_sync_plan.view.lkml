view: integrations_vic_t3__po_line_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_T3__PO_LINE_SYNC_PLAN" ;;

  dimension: pk_po_line_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
  }

  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }

  dimension: fk_vic_po_header_id {
    type: string
    sql: ${TABLE}."FK_VIC_PO_HEADER_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }

  dimension: product_description {
    type: string
    sql: ${TABLE}."PRODUCT_DESCRIPTION" ;;
  }

  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }

  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
  }

  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }

  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }

  dimension: amount_unit {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
  }

  dimension: line_item_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_TOTAL" ;;
  }

  dimension: fk_dim_department_id {
    type: string
    sql: ${TABLE}."FK_DIM_DEPARTMENT_ID" ;;
  }

  dimension: fk_dim_line_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_LINE_DESCRIPTION_ID" ;;
  }

  dimension: fk_dim_line_memo_id {
    type: string
    sql: ${TABLE}."FK_DIM_LINE_MEMO_ID" ;;
  }

  dimension: fk_dim_part_number_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_NUMBER_ID" ;;
  }

  dimension: fk_dim_part_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_DESCRIPTION_ID" ;;
  }

  dimension: fk_dim_part_provider_id {
    type: string
    sql: ${TABLE}."FK_DIM_PART_PROVIDER_ID" ;;
  }

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }

  set: detail {
    fields: [
      pk_po_line_id,
      fk_po_header_id,
      fk_vic_po_header_id,
      po_number,
      line_number,
      product_number,
      product_description,
      unit_of_measure,
      qty_ordered,
      qty_received,
      matching_type,
      amount_unit,
      line_item_total,
      fk_dim_department_id,
      fk_dim_line_description_id,
      fk_dim_line_memo_id,
      fk_dim_part_number_id,
      fk_dim_part_description_id,
      fk_dim_part_provider_id,
      action_to_take,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_unit {
    type: sum
    sql: ${TABLE}."AMOUNT_UNIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
