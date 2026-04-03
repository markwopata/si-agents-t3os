view: trackers {
  sql_table_name: "TRACKERS"."TRACKERS"
    ;;
  drill_fields: [tracker_id]

  dimension: tracker_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
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

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: battery_voltage_type_id {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
  }

  dimension: carrier_id {
    type: number
    sql: ${TABLE}."CARRIER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: config_status {
    type: string
    sql: ${TABLE}."CONFIG_STATUS" ;;
  }

  dimension: config_version {
    type: string
    sql: ${TABLE}."CONFIG_VERSION" ;;
  }

  dimension_group: created {
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
    sql: ${TABLE}.CAST(${TABLE}."CREATED" AS TIMESTAMP_NTZ) ;;
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

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: firmware_version {
    type: string
    sql: ${TABLE}."FIRMWARE_VERSION" ;;
  }

  dimension_group: first_report {
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
    sql: ${TABLE}.CAST(${TABLE}."FIRST_REPORT_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: gps_lock {
    type: yesno
    sql: ${TABLE}."GPS_LOCK" ;;
  }

  dimension: group {
    type: string
    sql: ${TABLE}."GROUP" ;;
  }

  dimension: iccid {
    type: string
    sql: ${TABLE}."ICCID" ;;
  }

  dimension: imei {
    type: string
    sql: ${TABLE}."IMEI" ;;
  }

  dimension_group: last_config_sync {
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
    sql: ${TABLE}.CAST(${TABLE}."LAST_CONFIG_SYNC_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_config_update {
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
    sql: ${TABLE}.CAST(${TABLE}."LAST_CONFIG_UPDATE_TIME" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_known_ip_address {
    type: string
    sql: ${TABLE}."LAST_KNOWN_IP_ADDRESS" ;;
  }

  dimension: last_known_port {
    type: number
    sql: ${TABLE}."LAST_KNOWN_PORT" ;;
  }

  dimension: modem_firmware_reflash_status {
    type: number
    sql: ${TABLE}."MODEM_FIRMWARE_REFLASH_STATUS" ;;
  }

  dimension: modem_firmware_version {
    type: string
    sql: ${TABLE}."MODEM_FIRMWARE_VERSION" ;;
  }

  dimension: modem_module {
    type: string
    sql: ${TABLE}."MODEM_MODULE" ;;
  }

  dimension: obd2_firmware_version {
    type: string
    sql: ${TABLE}."OBD2_FIRMWARE_VERSION" ;;
  }

  dimension: obd2_vehicle_db_version {
    type: string
    sql: ${TABLE}."OBD2_VEHICLE_DB_VERSION" ;;
  }

  dimension: part_info {
    type: string
    sql: ${TABLE}."PART_INFO" ;;
  }

  dimension: pending_config_version {
    type: string
    sql: ${TABLE}."PENDING_CONFIG_VERSION" ;;
  }

  dimension: pending_script_version {
    type: string
    sql: ${TABLE}."PENDING_SCRIPT_VERSION" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: script_version {
    type: string
    sql: ${TABLE}."SCRIPT_VERSION" ;;
  }

  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}."TRACKER_TYPE_ID" ;;
  }

  dimension: tracker_vendor_id {
    type: number
    sql: ${TABLE}."TRACKER_VENDOR_ID" ;;
  }

  dimension: twilio_sid {
    type: string
    sql: ${TABLE}."TWILIO_SID" ;;
  }

  dimension_group: updated {
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
    sql: ${TABLE}.CAST(${TABLE}."UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_id]
  }
}
