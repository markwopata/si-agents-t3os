view: vic_sandbox__po_lines {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__PO_LINES" ;;

  dimension: amount_unit {
    type: string
    sql: ${TABLE}."AMOUNT_UNIT" ;;
  }
  dimension: fk_dim_cc_line_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_CC_LINE_DESCRIPTION_ID" ;;
  }
  dimension: fk_dim_cc_line_memo_id {
    type: string
    sql: ${TABLE}."FK_DIM_CC_LINE_MEMO_ID" ;;
  }
  dimension: fk_dim_cc_part_description_id {
    type: string
    sql: ${TABLE}."FK_DIM_CC_PART_DESCRIPTION_ID" ;;
  }
  dimension: fk_dim_cc_part_number_id {
    type: string
    sql: ${TABLE}."FK_DIM_CC_PART_NUMBER_ID" ;;
  }
  dimension: fk_dim_cc_part_provider_id {
    type: string
    sql: ${TABLE}."FK_DIM_CC_PART_PROVIDER_ID" ;;
  }
  dimension: fk_dim_fleet_asset_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_ASSET_ID" ;;
  }
  dimension: fk_dim_fleet_attachment_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_ATTACHMENT_ID" ;;
  }
  dimension: fk_dim_fleet_date_week_to_be_paid_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_DATE_WEEK_TO_BE_PAID_ID" ;;
  }
  dimension: fk_dim_fleet_equipment_make_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_EQUIPMENT_MAKE_ID" ;;
  }
  dimension: fk_dim_fleet_equipment_model_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_EQUIPMENT_MODEL_ID" ;;
  }
  dimension: fk_dim_fleet_factory_build_specification_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_FACTORY_BUILD_SPECIFICATION_ID" ;;
  }
  dimension: fk_dim_fleet_finance_status_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_FINANCE_STATUS_ID" ;;
  }
  dimension: fk_dim_fleet_model_year_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_MODEL_YEAR_ID" ;;
  }
  dimension: fk_dim_fleet_name_submitter_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_NAME_SUBMITTER_ID" ;;
  }
  dimension: fk_dim_fleet_note_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_NOTE_ID" ;;
  }
  dimension: fk_dim_fleet_order_status_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_ORDER_STATUS_ID" ;;
  }
  dimension: fk_dim_fleet_pending_schedule_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_PENDING_SCHEDULE_ID" ;;
  }
  dimension: fk_dim_fleet_reconciliation_status_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_RECONCILIATION_STATUS_ID" ;;
  }
  dimension: fk_dim_fleet_serial_number_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_SERIAL_NUMBER_ID" ;;
  }
  dimension: fk_dim_fleet_vin_id {
    type: string
    sql: ${TABLE}."FK_DIM_FLEET_VIN_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }
  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }
  dimension: fk_vic_po_header_id {
    type: string
    sql: ${TABLE}."FK_VIC_PO_HEADER_ID" ;;
  }
  dimension: invoice_items_matched {
    type: string
    sql: ${TABLE}."INVOICE_ITEMS_MATCHED" ;;
  }
  dimension: matching_type {
    type: string
    sql: ${TABLE}."MATCHING_TYPE" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: pk_vic_po_line_id {
    type: string
    sql: ${TABLE}."PK_VIC_PO_LINE_ID" ;;
    primary_key: yes
  }
  dimension: po_line_number {
    type: number
    sql: ${TABLE}."PO_LINE_NUMBER" ;;
  }
  dimension: product_description {
    type: string
    sql: ${TABLE}."PRODUCT_DESCRIPTION" ;;
  }
  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }
  dimension: qty_accepted {
    type: string
    sql: ${TABLE}."QTY_ACCEPTED" ;;
  }
  dimension: qty_received {
    type: string
    sql: ${TABLE}."QTY_RECEIVED" ;;
  }
  dimension: qty_requested {
    type: string
    sql: ${TABLE}."QTY_REQUESTED" ;;
  }
  dimension: status_matching {
    type: string
    sql: ${TABLE}."STATUS_MATCHING" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: unit_of_measure {
    type: string
    sql: ${TABLE}."UNIT_OF_MEASURE" ;;
  }
  measure: count {
    type: count
  }
}
