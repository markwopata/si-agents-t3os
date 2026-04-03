view: trackers_mapping {
  derived_table: {
    sql: Select * from "ES_WAREHOUSE"."PUBLIC"."TRACKERS_MAPPING"
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: tracker_device_serial {
    type: string
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: keypad_controller_type_id {
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
  }

  dimension: tracker_tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_TRACKER_ID" ;;
  }

  dimension: esdb_tracker_id {
    type: number
    sql: ${TABLE}."ESDB_TRACKER_ID" ;;
  }

  set: detail {
    fields: [
      tracker_device_serial,
      tracker_vendor,
      asset_id,
      asset_name,
      company_id,
      asset_type,
      keypad_controller_type_id,
      tracker_tracker_id,
      esdb_tracker_id
    ]
  }
}
