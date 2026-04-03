view: integrations_vic_fleet_e7_sandbox__po_line_sync_plan {
  sql_table_name: "INTEGRATIONS_GOLD"."INTEGRATIONS_VIC_FLEET_E7_SANDBOX__PO_LINE_SYNC_PLAN" ;;

  dimension: action_to_take {
    type: string
    sql: ${TABLE}."ACTION_TO_TAKE" ;;
  }
  dimension: amount_unit {
    type: number
    sql: ${TABLE}."AMOUNT_UNIT" ;;
  }
  dimension: dim_asset {
    type: string
    sql: ${TABLE}."DIM_ASSET" ;;
  }
  dimension: dim_attachment {
    type: string
    sql: ${TABLE}."DIM_ATTACHMENT" ;;
  }
  dimension: dim_date_week_to_be_paid {
    type: string
    sql: ${TABLE}."DIM_DATE_WEEK_TO_BE_PAID" ;;
  }
  dimension: dim_equipment_make {
    type: string
    sql: ${TABLE}."DIM_EQUIPMENT_MAKE" ;;
  }
  dimension: dim_equipment_model {
    type: string
    sql: ${TABLE}."DIM_EQUIPMENT_MODEL" ;;
  }
  dimension: dim_factory_build_specifications {
    type: string
    sql: ${TABLE}."DIM_FACTORY_BUILD_SPECIFICATIONS" ;;
  }
  dimension: dim_model_year {
    type: string
    sql: ${TABLE}."DIM_MODEL_YEAR" ;;
  }
  dimension: dim_name_submitter {
    type: string
    sql: ${TABLE}."DIM_NAME_SUBMITTER" ;;
  }
  dimension: dim_note {
    type: string
    sql: ${TABLE}."DIM_NOTE" ;;
  }
  dimension: dim_pending_schedule {
    type: string
    sql: ${TABLE}."DIM_PENDING_SCHEDULE" ;;
  }
  dimension: dim_serial_number {
    type: string
    sql: ${TABLE}."DIM_SERIAL_NUMBER" ;;
  }
  dimension: dim_status_finance {
    type: string
    sql: ${TABLE}."DIM_STATUS_FINANCE" ;;
  }
  dimension: dim_status_order {
    type: string
    sql: ${TABLE}."DIM_STATUS_ORDER" ;;
  }
  dimension: dim_status_reconciliation {
    type: string
    sql: ${TABLE}."DIM_STATUS_RECONCILIATION" ;;
  }
  dimension: dim_vin {
    type: string
    sql: ${TABLE}."DIM_VIN" ;;
  }
  dimension: line_item_total {
    type: number
    sql: ${TABLE}."LINE_ITEM_TOTAL" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: pk_po_line_id {
    type: number
    sql: ${TABLE}."PK_PO_LINE_ID" ;;
    primary_key: yes
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
  dimension: type_matching {
    type: string
    sql: ${TABLE}."TYPE_MATCHING" ;;
  }
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  measure: count {
    type: count
  }
}
