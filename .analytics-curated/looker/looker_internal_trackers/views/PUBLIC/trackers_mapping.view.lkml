view: trackers_mapping {
  sql_table_name: "PUBLIC"."TRACKERS_MAPPING"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: esdb_tracker_id {
    type: number
    sql: ${TABLE}."ESDB_TRACKER_ID" ;;
  }

  dimension: keypad_controller_type_id {
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
  }

  dimension: tracker_device_serial {
    type: string
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }

  dimension: tracker_tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_TRACKER_ID" ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_name]
  }
}
