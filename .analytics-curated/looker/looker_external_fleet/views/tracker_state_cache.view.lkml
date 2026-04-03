view: tracker_state_cache {
  sql_table_name: "PUBLIC"."TRACKER_STATE_CACHE"
    ;;
  drill_fields: [tracker_state_cache_id]

  dimension: tracker_state_cache_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_STATE_CACHE_ID" ;;
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

  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }

  dimension: battery_voltage_is_low {
    type: yesno
    sql: ${TABLE}."BATTERY_VOLTAGE_IS_LOW" ;;
  }

  dimension_group: battery_voltage_timestamp {
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
    sql: CAST(${TABLE}."BATTERY_VOLTAGE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: current_keypad_code_update_log_id {
    type: number
    sql: ${TABLE}."CURRENT_KEYPAD_CODE_UPDATE_LOG_ID" ;;
  }

  dimension: current_keypad_code_update_request_id {
    type: number
    sql: ${TABLE}."CURRENT_KEYPAD_CODE_UPDATE_REQUEST_ID" ;;
  }

  dimension: current_trip_id {
    type: number
    sql: ${TABLE}."CURRENT_TRIP_ID" ;;
  }

  dimension: current_unhealthy_tracker_log_id {
    type: number
    sql: ${TABLE}."CURRENT_UNHEALTHY_TRACKER_LOG_ID" ;;
  }

  dimension: is_updating_odometer_on_trips {
    type: yesno
    sql: ${TABLE}."IS_UPDATING_ODOMETER_ON_TRIPS" ;;
  }

  dimension: latest_distance_accumulator {
    type: number
    sql: ${TABLE}."LATEST_DISTANCE_ACCUMULATOR" ;;
  }

  dimension_group: latest_gps_fix_timestamp {
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
    sql: CAST(${TABLE}."LATEST_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: latest_hdop {
    type: number
    sql: ${TABLE}."LATEST_HDOP" ;;
  }

  dimension: latest_idle_end_incident_id {
    type: number
    sql: ${TABLE}."LATEST_IDLE_END_INCIDENT_ID" ;;
  }

  dimension: latest_idle_start_incident_id {
    type: number
    sql: ${TABLE}."LATEST_IDLE_START_INCIDENT_ID" ;;
  }

  dimension_group: latest_reboot_timestamp {
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
    sql: CAST(${TABLE}."LATEST_REBOOT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: latest_report_timestamp {
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
    sql: CAST(${TABLE}."LATEST_REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: latest_rpm {
    type: number
    sql: ${TABLE}."LATEST_RPM" ;;
  }

  dimension: latest_rssi {
    type: number
    sql: ${TABLE}."LATEST_RSSI" ;;
  }

  dimension: latest_satellites {
    type: number
    sql: ${TABLE}."LATEST_SATELLITES" ;;
  }

  dimension: latest_sequence_number {
    type: number
    sql: ${TABLE}."LATEST_SEQUENCE_NUMBER" ;;
  }

  dimension: latest_speed_end_incident_id {
    type: number
    sql: ${TABLE}."LATEST_SPEED_END_INCIDENT_ID" ;;
  }

  dimension: latest_speed_start_incident_id {
    type: number
    sql: ${TABLE}."LATEST_SPEED_START_INCIDENT_ID" ;;
  }

  dimension: latest_time_fence_incident_id {
    type: number
    sql: ${TABLE}."LATEST_TIME_FENCE_INCIDENT_ID" ;;
  }

  dimension: open_idle_vbus_detect_log_id {
    type: number
    sql: ${TABLE}."OPEN_IDLE_VBUS_DETECT_LOG_ID" ;;
  }

  dimension: open_stale_gps_incident_log_id {
    type: number
    sql: ${TABLE}."OPEN_STALE_GPS_INCIDENT_LOG_ID" ;;
  }

  dimension: rapid_reboot_log_id {
    type: number
    sql: ${TABLE}."RAPID_REBOOT_LOG_ID" ;;
  }

  dimension: stuck_rpm_log_id {
    type: number
    sql: ${TABLE}."STUCK_RPM_LOG_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_state_cache_id]
  }

  dimension: tracker_connection_status {
    type: string
    sql: case
    when ${assets.tracker_id} is null then 'No Tracker'
    when ${tracker_unplugged_status.tracker_unplugged} = 'Yes' then 'Unplugged'
    when ${latest_rssi} <= -81 and ${latest_rssi} > -90 then 'Poor (-81/-90)'
    when ${latest_rssi} <= -90 then 'Unstable (-91+)'
    else 'Healthy (0/-80)' end  ;;
  }

  dimension: ranking_connection_status {
    type: number
    sql: case
          when ${tracker_connection_status} = 'No Tracker' then 1
          when ${tracker_connection_status} = 'Unplugged' then 2
          when ${tracker_connection_status} = 'Unstable (-91+)' then 3
          when ${tracker_connection_status} = 'Poor (-81/-90)' then 4
          else 5
          end;;
  }
}
