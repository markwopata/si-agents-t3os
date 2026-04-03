view: telematics_mothership {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__TELEMATICS_HEALTH" ;;

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
    value_format_name: id
    html: <font color="blue "><u><a href="https://app.estrack.com/#/assets/all/asset/{{asset_id}}/service" target="_blank">{{ asset_id._value }}</a></font></u> ;;
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension: asset_location {
    type:  location
    sql_latitude:  IFNULL(${lat},  ${last_delivery_lat}) ;;
    sql_longitude: IFNULL(${long}, ${last_delivery_long}) ;;
  }
  dimension: asset_health_detail {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_DETAIL" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: battery_voltage {
    label: "Tracker Battery Voltage"
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
  dimension_group: camera_install_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    description: "Timestamp of camera installation"
    sql: ${TABLE}.CAMERA_INSTALL_DATE ;;
  }
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: company_id {
    type: number
    value_format_name: id
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
  dimension: odometer {
    type: string
    description: "Asset odometer reading"
    sql: ${TABLE}.ODOMETER ;;
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
  dimension: ghost_tracker_id {
    type: number
    description: "Ghost tracker ID"
    sql: ${TABLE}.GHOST_TRACKER_ID ;;
  }
  dimension: ghost_tracker_serial {
    type: string
    description: "Serial number of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_SERIAL ;;
  }
  dimension: ghost_tracker_type {
    type: string
    description: "Type of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_TYPE ;;
  }
  dimension: ghost_tracker_vendor {
    type: string
    description: "Vendor of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_VENDOR ;;
  }
  dimension: ghost_tracker_last_checkin {
    type: string
    description: "Last check-in timestamp of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_LAST_CHECKIN ;;
  }
  dimension: ghost_tracker_health_status {
    type: string
    description: "Health status of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_HEALTH_STATUS ;;
  }
  dimension: ghost_tracker_req {
    type: string
    description: "Installation requirement for ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_REQ ;;
  }
  dimension: ghost_tracker_install_status {
    type: string
    description: "Install status of ghost tracker"
    sql: ${TABLE}.GHOST_TRACKER_INSTALL_STATUS ;;
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
  dimension: secondary_serial_with_trackers_manager_link {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_SERIAL" ;;
    link: {
      label: "Trackers Manager"
      url: "https://tracker-manager.equipmentshare.com/#/trackers/search?trackers={{ value | url_encode }}"
    }
    description: "This links out to the Trackers Manager Platform"
  }
  dimension: ghost_serial_with_trackers_manager_link {
    type: string
    sql: ${TABLE}."GHOST_TRACKER_SERIAL" ;;
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
  dimension: secondary_tracker_health_status {
    type:  string
    sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_STATUS";;
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

  dimension: test_status {
    type: string
    sql:  case when ${ghost_tracker_health_status} = 'HEALTHY' then 'HEALTHY'
      when ${ghost_tracker_health_status} IN ('UNSTABLE') THEN 'UNSTABLE'
      when ${ghost_tracker_health_status} IN ('NEEDS SERVICE ATTENTION','NEEDS TELEMATICS ATTENTION') then 'UNHEALTHY'
      when ${ghost_tracker_health_status} = 'UNSTABLE' then 'UNSTABLE'
      else 'NO STATUS'
      end;;
  }

  measure: avg_days_since_last_keypad_entry {
    type: average
    value_format_name: decimal_0
    drill_fields: [tracker_details*]
    sql:  datediff(days, ${TABLE}."LAST_KEYPAD_ENTRY_DATE", current_date()) ;;
  }

  dimension: secondary_tracker_status {
    type:  string
    sql: ${TABLE}."SECONDARY_TRACKER_STATUS";;
  }

  dimension: pending_keycode_count {
    type:  number
    sql: ${TABLE}."PENDING_KEYCODE_COUNT";;
  }

  dimension: pending_keycode {
    type:  string
    sql: CASE
           WHEN ${TABLE}."PENDING_KEYCODE_COUNT" >= 1 THEN 'PENDING KEYCODES'
           ELSE 'NO PENDING CODES'
           END;;
  }

  dimension: pending_aged_keycode {
    type:  string
    sql: CASE
           WHEN ${TABLE}."PENDING_KEYCODE_AGED_COUNT" >= 1 THEN 'PENDING KEYCODES'
           ELSE 'NO PENDING CODES'
           END;;
  }

  dimension: pending_keycode_aged_count {
    description: "Only showing keycodes pending > 3 days"
    type:  number
    sql: ${TABLE}."PENDING_KEYCODE_AGED_COUNT";;
  }

  dimension: battery_voltage_type {
    type:  string
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE";;
  }

  dimension: tracker_model {
    type:  string
    sql: ${TABLE}."TRACKER_MODEL";;
  }

  dimension: category {
    type:  string
    sql: ${TABLE}."CATEGORY";;
  }

  dimension: public_health_status {
    type:  string
    sql: ${TABLE}."PUBLIC_HEALTH_STATUS";;
  }

  dimension: last_delivery_drop_off_or_return {
    type: string
    sql: ${TABLE}.LAST_DELIVERY_DROP_OFF_OR_RETURN ;;
  }

  dimension_group: last_delivery_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.LAST_DELIVERY_DATE ;;
  }

  dimension: last_delivery_address {
    type: string
    sql: ${TABLE}.LAST_DELIVERY_ADDRESS ;;
  }

  dimension: last_delivery_contact_name {
    type: string
    sql: ${TABLE}.LAST_DELIVERY_CONTACT_NAME ;;
  }

  dimension: last_delivery_contact_phone {
    type: string
    sql: ${TABLE}.LAST_DELIVERY_CONTACT_PHONE ;;
  }

  dimension: last_delivery_lat {
    type: number
    value_format: "0.000000"
    sql: ${TABLE}.LAST_DELIVERY_LAT ;;
  }

  dimension: last_delivery_long {
    type: number
    value_format: "0.000000"
    sql: ${TABLE}.LAST_DELIVERY_LONG ;;
  }

  dimension_group: data_refresh_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    description: "Timestamp when this record was last updated in ETL"
    sql: ${TABLE}.DATA_REFRESH_TIMESTAMP ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_details*]
  }

  measure: count_with_ghost_details {
    type: count
    drill_fields: [tracker_details*, ghost_tracker_details*]
  }

  measure: count_with_secondary_details {
    type: count
    drill_fields: [secondary_tracker_details*]
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_id_with_name {
    type: string
    sql: ${TABLE}."MARKET_ID" || ' ' || ${TABLE}."MARKET_NAME" ;;
  }

  dimension: secondary_tracker_health_detail {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_DETAIL" ;;
  }

  dimension: renting_company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTING_COMPANY_ID" ;;
  }

  dimension: renting_company_name {
    type: string
    sql: ${TABLE}."RENTING_COMPANY_NAME" ;;
  }

  dimension: renting_company_id_with_name {
    type: string
    sql: ${TABLE}."RENTING_COMPANY_ID" || ' ' || ${TABLE}."RENTING_COMPANY_NAME" ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: asset_type_thr {
    type: string
    sql: ${TABLE}."ASSET_TYPE_THR" ;;
  }

  dimension_group: rssi_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RSSI_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_reporting_ready {
    type: yesno
    sql: ${TABLE}."IS_REPORTING_READY" ;;
  }

  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
  }

  dimension: service_branch {
    type: string
    sql: ${TABLE}."SERVICE_BRANCH" ;;
  }

  dimension: tracker_grouping {
    type: string
    sql: ${TABLE}."TRACKER_GROUPING" ;;
  }

  dimension: hdop {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."HDOP" ;;
  }

  dimension_group: hdop_timestamp {
    type: time
    convert_tz: no
    datatype: date
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."HDOP_TIMESTAMP" ;;
  }

  dimension_group: scheduled_off_rent_date {
    type: time
    convert_tz: no
    datatype: date
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
  }

  measure: telematics_health_score {
    type:  number
    drill_fields: [tracker_details*]
    value_format_name: "percent_1"
    sql:  (COUNT(DISTINCT IFF(UPPER(TRIM(${asset_health_status})) IN ('HEALTHY', 'UNSTABLE') AND ${tracker_id} IS NOT NULL, ${asset_id}, NULL)) * 1.0)
          / NULLIF(
           COUNT(DISTINCT IFF(UPPER(TRIM(${asset_health_status})) <> 'NO TRACKER INSTALLED' AND ${tracker_id} IS NOT NULL, ${asset_id}, NULL)),
          0
      );;
  }

  measure: telematics_install_score {
    type:  number
    drill_fields: [tracker_details*]
    value_format_name: "percent_1"
    sql:  (COUNT(DISTINCT IFF(UPPER(TRIM(${tracker_install_status})) IN ('CORRECT TRACKER') AND ${tracker_id} IS NOT NULL, ${asset_id}, NULL)) * 1.0)
          / NULLIF(
           COUNT(DISTINCT IFF(UPPER(TRIM(${tracker_install_status})) <> 'NO TRACKER NEEDED', ${asset_id}, NULL)),
          0
      );;
  }

  measure: camera_health_score {
    type:  number
    drill_fields: [tracker_details*]
    value_format_name: "percent_1"
    sql:  (COUNT(DISTINCT IFF(UPPER(TRIM(${camera_health})) IN ('CAMERA HEALTH OK') AND ${camera_id} IS NOT NULL, ${asset_id}, NULL)) * 1.0)
          / NULLIF(
           COUNT(DISTINCT IFF(UPPER(TRIM(${camera_health})) <> 'NO CAMERA INSTALLED' AND ${camera_id} IS NOT NULL, ${asset_id}, NULL)),
          0
      );;
  }

  measure: camera_install_score {
    type:  number
    drill_fields: [tracker_details*]
    value_format_name: "percent_1"
    sql:  (COUNT(DISTINCT IFF(UPPER(TRIM(${camera_install_status})) IN ('CAMERA') AND ${camera_id} IS NOT NULL, ${asset_id}, NULL)) * 1.0)
          / NULLIF(
           COUNT(DISTINCT IFF(UPPER(TRIM(${camera_install_status})) <> 'NO CAMERA REQUIRED', ${asset_id}, NULL)),
          0
      );;
  }

  measure: keypad_install_score {
    type:  number
    drill_fields: [tracker_details*]
    value_format_name: "percent_1"
    sql:  (COUNT(DISTINCT IFF(UPPER(TRIM(${keypad_install_status})) IN ('KEYPAD') AND ${keypad_id} IS NOT NULL, ${asset_id}, NULL)) * 1.0)
          / NULLIF(
           COUNT(DISTINCT IFF(UPPER(TRIM(${keypad_install_status})) <> 'NO KEYPAD REQUIRED', ${asset_id}, NULL)),
          0
      );;
  }

  set: tracker_details {
    fields:  [asset_id_with_t3_service_link,
      telematics_mothership.custom_name,
      market_name,
      service_branch,
      company_name,
      district,
      region,
      make,
      model,
      asset_class,
      asset_inventory_status,
      asset_purchase_history.oec,
      asset_health_detail,
      asset_health_status,
      public_health_status,
      tracker_req_type,
      tracker_model,
      # tracker_type,
      tracker_install_status,
      tracker_id,
      serial_with_trackers_manager_link,
      last_trip_date_time,
      last_checkin_timestamp_time,
      latest_satellites,
      rssi,
      telematics_mothership.hdop,
      latest_report_timestamp_time,
      start_stale_gps_fix_timestamp_time,
      latest_gps_fix_timestamp_time,
      last_location_timestamp_time,
      last_delivery_date_time,
      last_delivery_drop_off_or_return,
      last_delivery_address,
      last_delivery_contact_name,
      last_delivery_contact_phone,
      scheduled_off_rent_date_date,
      renting_company_name,
      days_since_last_checkin,
      asset_battery_voltage,
      battery_voltage,
      current_morey_vbus_configuration_only.Current_VBUS,
      fact_tracker_vbus_events.event_count,
      fact_tracker_vbus_events.engine_rpm,
      fact_tracker_vbus_events.engine_rpm_latest_event_time,
      tracker_serial,
      tracker_last_date_installed_time,
      tracker_firmware_version,
      keypad_req,
      keypad_install_status,
      pending_keycode,
      pending_keycode_count,
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
      last_camera_heartbeat_date,
      test_status]
  }

  set: ghost_tracker_details {
    fields:  [ghost_serial_with_trackers_manager_link,
      ghost_tracker_install_status,
      ghost_tracker_health_status,
      ghost_tracker_last_checkin]
  }

  set: secondary_tracker_details {
    fields:  [asset_id,
      make,
      model,
      secondary_serial_with_trackers_manager_link,
      secondary_tracker_install_status,
      secondary_tracker_req,
      secondary_tracker_health_status,
      secondary_tracker_health_detail,
      secondary_tracker_last_checkin,
      ]
  }

}
