view: trackers_keypads {
  sql_table_name: "ES_WAREHOUSE"."TRACKERS"."KEYPADS"
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [keypad_id]
  }
}
