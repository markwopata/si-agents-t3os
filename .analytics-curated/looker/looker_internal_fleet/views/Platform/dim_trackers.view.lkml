view: dim_trackers {
  sql_table_name: "PLATFORM"."GOLD"."DIM_TRACKERS" ;;

  dimension: tracker_battery_voltage {
    type: number
    sql: ${TABLE}."TRACKER_BATTERY_VOLTAGE" ;;
  }
  dimension: tracker_ble_on_off {
    type: string
    sql: ${TABLE}."TRACKER_BLE_ON_OFF" ;;
  }
  dimension: tracker_company_id {
    type: number
    sql: ${TABLE}."TRACKER_COMPANY_ID" ;;
  }
  dimension: tracker_company_key {
    type: string
    sql: ${TABLE}."TRACKER_COMPANY_KEY" ;;
  }
  dimension_group: tracker_date_installed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_DATE_INSTALLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: tracker_device_serial {
    type: string
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }
  dimension: tracker_firmware_version {
    type: string
    sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
  }
  dimension: tracker_iccid {
    type: string
    sql: ${TABLE}."TRACKER_ICCID" ;;
  }
  dimension: tracker_id_esdb {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_ID_ESDB" ;;
  }
  dimension: tracker_id_trackersdb {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_ID_TRACKERSDB" ;;
  }
  dimension: tracker_key {
    type: string
    sql: ${TABLE}."TRACKER_KEY" ;;
  }
  dimension_group: tracker_latest_gps_fix_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_LATEST_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: tracker_latest_location_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_LATEST_LOCATION_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: tracker_latest_report_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_LATEST_REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: tracker_latest_satellites {
    type: number
    sql: ${TABLE}."TRACKER_LATEST_SATELLITES" ;;
  }
  dimension: tracker_latest_sequence_number {
    type: number
    sql: ${TABLE}."TRACKER_LATEST_SEQUENCE_NUMBER" ;;
  }
  dimension: tracker_phone_number {
    type: string
    sql: ${TABLE}."TRACKER_PHONE_NUMBER" ;;
  }
  dimension_group: tracker_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TRACKER_RECORDTIMESTAMP" ;;
  }
  dimension: tracker_source {
    type: string
    sql: ${TABLE}."TRACKER_SOURCE" ;;
  }
  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}."TRACKER_TYPE_ID" ;;
  }
  dimension: tracker_type_name {
    type: string
    sql: ${TABLE}."TRACKER_TYPE_NAME" ;;
  }
  dimension: tracker_vendor_id {
    type: number
    sql: ${TABLE}."TRACKER_VENDOR_ID" ;;
  }
  dimension: tracker_vendor_name {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [tracker_type_name, tracker_vendor_name]
  }
}
