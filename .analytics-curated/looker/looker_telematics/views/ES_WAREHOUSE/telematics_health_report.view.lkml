view: telematics_health_report {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."TELEMATICS_HEALTH_REPORT"
    ;;

  dimension: asset_battery_voltage {
    type: string
    sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }

  dimension: ble_on_off {
    type: string
    sql: ${TABLE}."BLE_ON_OFF" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
  }

  dimension: hours {
    type: string
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: is_ble_node {
    type: string
    sql: ${TABLE}."IS_BLE_NODE" ;;
  }

  dimension: last_checkin_timestamp {
    type: string
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  dimension: last_location {
    type: string
    sql: ${TABLE}."LAST_LOCATION" ;;
  }

  dimension: last_location_geo {
    type: location
    sql_latitude: SPLIT_PART(${TABLE}."LAST_LOCATION",',',1);;
    sql_longitude: SPLIT_PART(${TABLE}."LAST_LOCATION",',',2);;
  }

  dimension: last_location_timestamp {
    type: string
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."LATEST_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
    sql: ${TABLE}.CAST(${TABLE}."LATEST_REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: latest_satellites {
    type: number
    sql: ${TABLE}."LATEST_SATELLITES" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  }

  dimension_group: out_of_lock_timestamp {
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
    sql: ${TABLE}.CAST(${TABLE}."OUT_OF_LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: rssi {
    type: number
    sql: ${TABLE}."RSSI" ;;
  }

  dimension_group: rssi_timestamp {
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
    sql: ${TABLE}.CAST(${TABLE}."RSSI_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: start_stale_gps_fix_timestamp {
    type: string
    sql: ${TABLE}."START_STALE_GPS_FIX_TIMESTAMP" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: tracker_firmware_version {
    type: string
    sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension_group: tracker_last_date_installed {
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
    sql: ${TABLE}.CAST(${TABLE}."TRACKER_LAST_DATE_INSTALLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tracker_type {
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }

  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }

  dimension: unplugged {
    type: string
    sql: ${TABLE}."UNPLUGGED" ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
