view: tracker_firmware_version_log {
  sql_table_name: "ES_WAREHOUSE"."TRACKERS"."TRACKER_FIRMWARE_VERSION_LOG"
    ;;
  drill_fields: [tracker_firmware_version_log_id]

  dimension: tracker_firmware_version_log_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_FIRMWARE_VERSION_LOG_ID" ;;
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

  dimension: end_timestamp {
    type: date_time
    sql: CAST(${TABLE}."END_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: firmware_version {
    type: string
    sql: ${TABLE}."FIRMWARE_VERSION" ;;
  }

  dimension_group: start_timestamp {
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
    sql: CAST(${TABLE}."START_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_firmware_version_log_id]
  }
}
