view: integrations_vic_costcapture_sandbox__po_line_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_COSTCAPTURE_SANDBOX__PO_LINE_SYNC_PLAN" ;;

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }
  dimension: amount_unit {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT" ;;
  }
  dimension: dim_line_description {
    type: string
    sql: ${TABLE}."DIM_LINE_DESCRIPTION" ;;
  }
  dimension: dim_line_memo {
    type: string
    sql: ${TABLE}."DIM_LINE_MEMO" ;;
  }
  dimension: dim_part_description_id {
    type: string
    sql: ${TABLE}."DIM_PART_DESCRIPTION_ID" ;;
  }
  dimension: dim_part_number_id {
    type: string
    sql: ${TABLE}."DIM_PART_NUMBER_ID" ;;
  }
  dimension: dim_part_provider_id {
    type: string
    sql: ${TABLE}."DIM_PART_PROVIDER_ID" ;;
  }
  dimension: fk_po_header_id {
    type: string
    sql: ${TABLE}."FK_PO_HEADER_ID" ;;
  }
  dimension: line_item_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_TOTAL" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
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
  dimension: product_description {
    type: string
    sql: ${TABLE}."PRODUCT_DESCRIPTION" ;;
  }
  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }
  dimension: qty_ordered {
    type: number
    sql: ${TABLE}."QTY_ORDERED" ;;
  }
  dimension: qty_received {
    type: number
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  measure: count {
    type: count
  }
}
