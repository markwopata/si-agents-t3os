view: telematics_mothership {
  sql_table_name: "ANALYTICS"."BI_OPS"."TELEMATICS_MOTHERSHIP" ;;

  dimension: asset_battery_voltage {
    type: number
    sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_health_status {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
  }
  dimension: asset_id {
    primary_key: yes
    type: string
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_id_with_t3_service_link {
    type: number
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{asset_id}}/service" target="_blank">{{ asset_id._value }}</a></font></u> ;;
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }
  dimension: ble_on_off {
    type: string
    sql: ${TABLE}."BLE_ON_OFF" ;;
  }
  dimension: camera_id {
    type: number
    sql: ${TABLE}."CAMERA_ID" ;;
  }
  dimension: camera_install_status {
    type: string
    sql: ${TABLE}."CAMERA_INSTALL_STATUS" ;;
  }
  dimension: camera_req {
    type: string
    sql: ${TABLE}."CAMERA_REQ" ;;
  }
  dimension: camera_serial {
    type: string
    value_format_name: id
    sql: ${TABLE}."CAMERA_SERIAL" ;;
  }
  dimension: camera_vendor {
    type: string
    sql: ${TABLE}."CAMERA_VENDOR" ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
  }
  dimension: dead_battery {
    type: string
    sql: ${TABLE}."DEAD_BATTERY" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: ecm_app {
    type: string
    sql: ${TABLE}."ECM_APP" ;;
  }
  dimension: ecm_bootloader {
    type: string
    sql: ${TABLE}."ECM_BOOTLOADER" ;;
  }
  dimension: ecm_hardware {
    type: string
    sql: ${TABLE}."ECM_HARDWARE" ;;
  }
  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
  }
  dimension: has_can {
    type: string
    sql: ${TABLE}."HAS_CAN" ;;
  }
  dimension: hours {
    type: string
    sql: ${TABLE}."HOURS" ;;
  }
  dimension: is_ble_node {
    type: string
    sql: ${TABLE}."IS_BLE_NODE" ;;
  }
  dimension: keypad_app {
    type: string
    sql: ${TABLE}."KEYPAD_APP" ;;
  }
  dimension: keypad_bootloader {
    type: string
    sql: ${TABLE}."KEYPAD_BOOTLOADER" ;;
  }
  dimension: keypad_hardware {
    type: string
    sql: ${TABLE}."KEYPAD_HARDWARE" ;;
  }
  dimension: keypad_id {
    type: number
    sql: ${TABLE}."KEYPAD_ID" ;;
  }
  dimension: keypad_install_status {
    type: string
    sql: ${TABLE}."KEYPAD_INSTALL_STATUS" ;;
  }
  dimension: keypad_req {
    type: string
    sql: ${TABLE}."KEYPAD_REQ" ;;
  }
  dimension: keypad_req_type {
    type: string
    sql: ${TABLE}."KEYPAD_REQ_TYPE" ;;
  }
  dimension: keypad_serial {
    type: string
    value_format_name: id
    sql: ${TABLE}."KEYPAD_SERIAL" ;;
  }
  dimension: last_address {
    type: string
    sql: ${TABLE}."LAST_ADDRESS" ;;
  }
  dimension_group: last_camera_heartbeat {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LAST_CAMERA_HEARTBEAT" ;;
  }
  dimension_group: last_cellular_contact {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_CELLULAR_CONTACT" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: last_checkin_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_CHECKIN_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: last_keycode_assignment_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_KEYCODE_ASSIGNMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: last_keycode_assignment_status {
    type: string
    sql: ${TABLE}."LAST_KEYCODE_ASSIGNMENT_STATUS" ;;
  }
  dimension_group: last_keypad_entry_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_KEYPAD_ENTRY_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: last_trip_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_TRIP_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: last_location {
    type: string
    sql: ${TABLE}."LAST_LOCATION" ;;
  }
  dimension_group: last_location_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_LOCATION_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: lat {
    type: string
    sql: ${TABLE}."LAT" ;;
  }
  dimension_group: latest_gps_fix_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LATEST_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: latest_report_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LATEST_REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: latest_satellites {
    type: number
    sql: ${TABLE}."LATEST_SATELLITES" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: long {
    type: string
    sql: ${TABLE}."LONG" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: max_voltage {
    type: number
    sql: ${TABLE}."MAX_VOLTAGE" ;;
  }
  dimension_group: max_voltage {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MAX_VOLTAGE_DATE" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }
  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: rssi {
    type: string
    sql: ${TABLE}."RSSI" ;;
  }
  dimension: secondary_tracker_req {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_REQ" ;;
  }
  dimension: secondary_tracker_id {
    type: number
    sql: ${TABLE}."SECONDARY_TRACKER_ID" ;;
  }
  dimension: secondary_tracker_install_status {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_INSTALL_STATUS" ;;
  }
  dimension: secondary_tracker_last_checkin {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_LAST_CHECKIN" ;;
  }
  dimension: secondary_tracker_serial {
    type: string
    value_format_name: id
    sql: ${TABLE}."SECONDARY_TRACKER_SERIAL" ;;
  }
  dimension: secondary_tracker_type {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_TYPE" ;;
  }
  dimension: secondary_tracker_vendor {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_VENDOR" ;;
  }
  dimension: serial_vin {
    type: string
    value_format_name: id
    sql: ${TABLE}."SERIAL_VIN" ;;
  }
  dimension: serial_with_trackers_manager_link {
    type: string
    sql: ${TABLE}."TRACKER_SERIAL" ;;
    link: {
      label: "Trackers Manager"
      url: "https://tracker-manager.equipmentshare.com/#/trackers/search?trackers={{ value | url_encode }}"
    }
    description: "This links out to the Trackers Manager Platform"
  }
  dimension_group: start_stale_gps_fix_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_STALE_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }
  dimension: telematics_region {
    type: string
    sql: ${TABLE}."TELEMATICS_REGION" ;;
  }
  dimension: tracker {
    type: string
    sql: ${TABLE}."TRACKER" ;;
  }
  dimension: tracker_firmware_version {
    type: string
    sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
  }
  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }
  dimension: tracker_install_status {
    type: string
    sql: ${TABLE}."TRACKER_INSTALL_STATUS" ;;
  }
  dimension_group: tracker_last_date_installed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TRACKER_LAST_DATE_INSTALLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: tracker_req_type {
    type: string
    sql: ${TABLE}."TRACKER_REQ_TYPE" ;;
  }
  dimension: tracker_serial {
    type: string
    value_format_name: id
    sql: ${TABLE}."TRACKER_SERIAL" ;;
  }
  dimension: tracker_type {
    type: string
    sql: ${TABLE}."TRACKER_TYPE" ;;
  }
  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}."TRACKER_TYPE_ID" ;;
  }
  dimension: tracker_vendor {
    type: string
    sql: ${TABLE}."TRACKER_VENDOR" ;;
  }
  dimension: unplugged {
    type: string
    sql: ${TABLE}."UNPLUGGED" ;;
  }
  dimension: year {
    type: string
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }
  dimension: camera_health {
    type:  string
    sql: ${TABLE}."CAMERA_HEALTH";;
  }
  dimension: secondary_tracker_health {
    type:  string
    sql: ${TABLE}."SECONDARY_TRACKER_HEALTH";;
  }
  dimension: days_btwn_keypad_entry_and_trip {
    type:  number
    sql:  ${TABLE}."DAYS_BTWN_KEYPAD_ENTRY_AND_TRIP" ;;
  }
  dimension: keypad_vs_trip_health {
    type:  string
    sql: ${TABLE}."KEYPAD_VS_TRIP_HEALTH";;
  }

  dimension: days_since_last_checkin {
    type: number
    value_format_name: decimal_0
    drill_fields: [tracker_details*]
    sql:  datediff(days, ${TABLE}."LAST_CHECKIN_TIMESTAMP", current_date()) ;;
  }

  dimension: days_since_last_checkin_groups {
    type: string
    value_format_name: decimal_0
    drill_fields: [tracker_details*]
    sql:  case when ${days_since_last_checkin} <= 1 then 'Healthy'
          when ${days_since_last_checkin} <= 7            then '<= 7 days'
          when ${days_since_last_checkin} <= 30           then '<=30 days'
          when ${days_since_last_checkin} <= 60           then '<=60 days'
          when ${days_since_last_checkin} >  60           then '> 60 days'
          else 'No checkin'
          end;;
  }

  dimension: days_since_last_checkin_groups_sort_order {
    type: string
    value_format_name: decimal_0
    drill_fields: [tracker_details*]
    sql:  case when ${days_since_last_checkin} <= 1       then '1'
               when ${days_since_last_checkin} <= 7       then '2'
               when ${days_since_last_checkin} <= 30      then '3'
               when ${days_since_last_checkin} <= 60      then '4'
               when ${days_since_last_checkin} >  60      then '5'
          else '6'
          end;;
  }

  dimension: tracker_installed_and_working {
    type: yesno
    sql: ${asset_health_status} = 'HEALTHY' ;;
  }

  measure: avg_days_since_last_keypad_entry {
    type: average
    value_format_name: decimal_0
    drill_fields: [tracker_details*]
    sql:  datediff(days, ${TABLE}."LAST_KEYPAD_ENTRY_DATE", current_date()) ;;
  }


  measure: count {
    type: count
    drill_fields: [tracker_details*]
  }

  measure: count_with_secondary_details {
    type: count
    drill_fields: [tracker_details*, secondary_tracker_details*]
  }

  set: tracker_details {
    fields:  [asset_id_with_t3_service_link,
      market_name,
      company_name,
      district,
      region,
      make,
      model,
      asset_class,
      asset_status,
      asset_inventory_status,
      tracker_req_type,
      tracker_type,
      tracker_install_status,
      tracker_id,
      serial_with_trackers_manager_link,
      last_trip_date_time,
      last_checkin_timestamp_time,
      latest_satellites,
      rssi,
      latest_report_timestamp_time,
      start_stale_gps_fix_timestamp_time,
      latest_gps_fix_timestamp_time,
      last_location_timestamp_time,
      days_since_last_checkin,
      asset_battery_voltage,
      asset_health_status,
      has_can,
      tracker_serial,
      tracker_firmware_version,
      keypad_req,
      keypad_install_status,
      keypad_serial,
      keypad_hardware,
      keypad_app,
      keypad_bootloader,
      ecm_hardware,
      ecm_app,
      ecm_bootloader,
      last_keypad_entry_date_date,
      camera_req,
      camera_install_status,
      camera_serial,
      camera_vendor,
      camera_health,
      last_camera_heartbeat_date]
  }

  set: secondary_tracker_details {
    fields:  [secondary_tracker_serial,
      secondary_tracker_install_status,
      secondary_tracker_health,
      secondary_tracker_last_checkin]
  }
}
