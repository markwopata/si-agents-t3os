view: lease_accelerator_cost_center_mapping {
  sql_table_name: "LEASE_ACCELERATOR"."LEASE_ACCELERATOR_COST_CENTER_MAPPING" ;;

  dimension: admin_asset_id {
    type: string
    sql: ${TABLE}."ADMIN_ASSET_ID" ;;
  }
  dimension: asset_cost_local {
    type: number
    sql: ${TABLE}."ASSET_COST_LOCAL" ;;
    value_format: "$#,##0.00"

  }
  dimension: asset_reference_number {
    type: string
    sql: ${TABLE}."ASSET_REFERENCE_NUMBER" ;;
  }
  dimension: asset_rent_local {
    type: number
    sql: ${TABLE}."ASSET_RENT_LOCAL" ;;
    value_format: "$#,##0.00"

  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: booking_ledger_date {
    type: string
    sql: ${TABLE}."BOOKING_LEDGER_DATE" ;;
  }
  dimension: commencement_date {
    type: string
    sql: ${TABLE}."COMMENCEMENT_DATE" ;;
  }
  dimension: date_entered {
    type: string
    sql: ${TABLE}."DATE_ENTERED" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: effective_end_date {
    type: string
    sql: ${TABLE}."EFFECTIVE_END_DATE" ;;
  }
  dimension: host_name {
    type: string
    sql: ${TABLE}."HOST_NAME" ;;
  }
  dimension: las_asset_id {
    type: string
    sql: ${TABLE}."LAS_ASSET_ID" ;;
  }
  dimension: las_cost_center {
    type: string
    sql: ${TABLE}."LAS_COST_CENTER" ;;
  }
  dimension: lease {
    type: string
    sql: ${TABLE}."LEASE" ;;
  }
  dimension: lease_genre {
    type: string
    sql: ${TABLE}."LEASE_GENRE" ;;
  }
  dimension: ledger_category {
    type: string
    sql: ${TABLE}."LEDGER_CATEGORY" ;;
  }
  dimension: manufacturer {
    type: string
    sql: ${TABLE}."MANUFACTURER" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_id_match {
    type: yesno
    sql: ${TABLE}."MARKET_ID_MATCH" ;;
  }
  dimension: market_id_name {
    type: string
    sql: ${TABLE}."MARKET_ID_NAME" ;;
  }
  dimension: months_remaining {
    type: string
    sql: ${TABLE}."MONTHS_REMAINING" ;;
  }
  dimension: original_end_date {
    type: string
    sql: ${TABLE}."ORIGINAL_END_DATE" ;;
  }
  dimension: product_number {
    type: string
    sql: ${TABLE}."PRODUCT_NUMBER" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: term {
    type: string
    sql: ${TABLE}."TERM" ;;
  }
  measure: count {
    type: count
    drill_fields: [host_name, market_id_name]
  }
}
