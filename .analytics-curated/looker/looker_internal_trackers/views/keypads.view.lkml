view: keypads {
  sql_table_name: "TRACKERS"."KEYPADS"
    ;;
  drill_fields: [keypad_id]

  dimension: keypad_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."KEYPAD_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: firmware_version {
    type: string
    sql: ${TABLE}."FIRMWARE_VERSION" ;;
  }

  dimension: keypad_controller_type_id {
    type: number
    sql: ${TABLE}."KEYPAD_CONTROLLER_TYPE_ID" ;;
  }

  dimension: keypad_firmware_id {
    type: number
    sql: ${TABLE}."KEYPAD_FIRMWARE_ID" ;;
  }

  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }

  dimension: tracker_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: keypads_count {
    type: count_distinct
    sql: ${keypad_controller_type_id} ;;
    drill_fields: [keypad_controller_type_id, keypad_id]
  }

  measure: count {
    type: count
    drill_fields: [keypad_id, keypad_controller_type_id, trackers.tracker_id]
  }
}
