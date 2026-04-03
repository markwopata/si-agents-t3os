view: telematics_health {
    # derived_table: {
    #   sql:
    #   SELECT DISTINCT
    #     asset_id
    #   , public_health_status
    #   , asset_health_detail
    #   , is_reporting_ready
    #   data_refresh_timestamp
    #   --*
    #   FROM
    #   "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__TELEMATICS_HEALTH"
    #   ;;
    # }
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__TELEMATICS_HEALTH" ;;

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: asset_id {
      type: number
      sql: ${TABLE}."ASSET_ID" ;;
    }

    # dimension: custom_name {
    #   type: string
    #   sql: ${TABLE}."CUSTOM_NAME" ;;
    # }

    # dimension: serial_vin {
    #   type: string
    #   sql: ${TABLE}."SERIAL_VIN" ;;
    # }

    # dimension: make {
    #   type: string
    #   sql: ${TABLE}."MAKE" ;;
    # }

    # dimension: model {
    #   type: string
    #   sql: ${TABLE}."MODEL" ;;
    # }

    # dimension: year {
    #   type: number
    #   sql: ${TABLE}."YEAR" ;;
    # }

    # dimension: asset_class {
    #   type: string
    #   sql: ${TABLE}."ASSET_CLASS" ;;
    # }

    # dimension: asset_type {
    #   type: string
    #   sql: ${TABLE}."ASSET_TYPE" ;;
    # }

    # dimension: asset_type_thr {
    #   type: string
    #   sql: ${TABLE}."ASSET_TYPE_THR" ;;
    # }

    # dimension: company_id {
    #   type: number
    #   sql: ${TABLE}."COMPANY_ID" ;;
    # }

    # dimension: company_name {
    #   type: string
    #   sql: ${TABLE}."COMPANY_NAME" ;;
    # }

    # dimension: asset_inventory_status {
    #   type: string
    #   sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
    # }

    # dimension: market_id {
    #   type: number
    #   sql: ${TABLE}."MARKET_ID" ;;
    # }

    # dimension: market_name {
    #   type: string
    #   sql: ${TABLE}."MARKET_NAME" ;;
    # }

    # dimension: district {
    #   type: string
    #   sql: ${TABLE}."DISTRICT" ;;
    # }

    # dimension: region {
    #   type: string
    #   sql: ${TABLE}."REGION" ;;
    # }

    # dimension: telematics_region {
    #   type: string
    #   sql: ${TABLE}."TELEMATICS_REGION" ;;
    # }

    # dimension: ownership {
    #   type: string
    #   sql: ${TABLE}."OWNERSHIP" ;;
    # }

    # dimension: inventory_branch {
    #   type: string
    #   sql: ${TABLE}."INVENTORY_BRANCH" ;;
    # }

    # dimension: tracker_id {
    #   type: number
    #   sql: ${TABLE}."TRACKER_ID" ;;
    # }

    # dimension: tracker_serial {
    #   type: string
    #   sql: ${TABLE}."TRACKER_SERIAL" ;;
    # }

    # dimension: device_serial {
    #   type: string
    #   sql: ${TABLE}."DEVICE_SERIAL" ;;
    # }

    # dimension: tracker_type_id {
    #   type: number
    #   sql: ${TABLE}."TRACKER_TYPE_ID" ;;
    # }

    # dimension: tracker_vendor {
    #   type: string
    #   sql: ${TABLE}."TRACKER_VENDOR" ;;
    # }

    # dimension: tracker_type {
    #   type: string
    #   sql: ${TABLE}."TRACKER_TYPE" ;;
    # }

    # dimension: tracker {
    #   type: string
    #   sql: ${TABLE}."TRACKER" ;;
    # }

    # dimension: phone_number {
    #   type: string
    #   sql: ${TABLE}."PHONE_NUMBER" ;;
    # }

    # dimension_group: tracker_last_date_installed {
    #   type: time
    #   sql: ${TABLE}."TRACKER_LAST_DATE_INSTALLED" ;;
    # }

    # dimension_group: latest_report_timestamp {
    #   type: time
    #   sql: ${TABLE}."LATEST_REPORT_TIMESTAMP" ;;
    # }

    # dimension: battery_voltage {
    #   type: number
    #   sql: ${TABLE}."BATTERY_VOLTAGE" ;;
    # }

    # dimension: tracker_firmware_version {
    #   type: string
    #   sql: ${TABLE}."TRACKER_FIRMWARE_VERSION" ;;
    # }

    # dimension: ble_on_off {
    #   type: string
    #   sql: ${TABLE}."BLE_ON_OFF" ;;
    # }

    # dimension: geofences {
    #   type: string
    #   sql: ${TABLE}."GEOFENCES" ;;
    # }

    # dimension: last_location {
    #   type: string
    #   sql: ${TABLE}."LAST_LOCATION" ;;
    # }

    # dimension: is_ble_node {
    #   type: string
    #   sql: ${TABLE}."IS_BLE_NODE" ;;
    # }

    # dimension: unplugged {
    #   type: string
    #   sql: ${TABLE}."UNPLUGGED" ;;
    # }

    # dimension: street {
    #   type: string
    #   sql: ${TABLE}."STREET" ;;
    # }

    # dimension: city {
    #   type: string
    #   sql: ${TABLE}."CITY" ;;
    # }

    # dimension: state {
    #   type: string
    #   sql: ${TABLE}."STATE" ;;
    # }

    # dimension: zip_code {
    #   type: string
    #   sql: ${TABLE}."ZIP_CODE" ;;
    # }

    # dimension: location {
    #   type: string
    #   sql: ${TABLE}."LOCATION" ;;
    # }

    # dimension_group: last_checkin_timestamp {
    #   type: time
    #   sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
    # }

    # dimension: asset_battery_voltage {
    #   type: number
    #   sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
    # }

    # dimension: start_stale_gps_fix_timestamp {
    #   type: string
    #   sql: ${TABLE}."START_STALE_GPS_FIX_TIMESTAMP" ;;
    # }

    # dimension_group: last_location_timestamp {
    #   type: time
    #   sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
    # }

    # dimension_group: latest_gps_fix_timestamp {
    #   type: time
    #   sql: ${TABLE}."LATEST_GPS_FIX_TIMESTAMP" ;;
    # }

    # dimension: latest_satellites {
    #   type: number
    #   sql: ${TABLE}."LATEST_SATELLITES" ;;
    # }

    # dimension: rssi {
    #   type: string
    #   sql: ${TABLE}."RSSI" ;;
    # }

    # dimension_group: rssi_timestamp {
    #   type: time
    #   sql: ${TABLE}."RSSI_TIMESTAMP" ;;
    # }

    # dimension_group: last_cellular_contact {
    #   type: time
    #   sql: ${TABLE}."LAST_CELLULAR_CONTACT" ;;
    # }

    # dimension: hours {
    #   type: number
    #   sql: ${TABLE}."HOURS" ;;
    # }

    # dimension: lat {
    #   type: number
    #   sql: ${TABLE}."LAT" ;;
    # }

    # dimension: long {
    #   type: number
    #   sql: ${TABLE}."LONG" ;;
    # }

    # dimension: dead_battery {
    #   type: string
    #   sql: ${TABLE}."DEAD_BATTERY" ;;
    # }

    dimension: asset_health_detail {
      type: string
      sql: ${TABLE}."ASSET_HEALTH_DETAIL" ;;
    }

    # dimension: last_address {
    #   type: string
    #   sql: ${TABLE}."LAST_ADDRESS" ;;
    # }

    # dimension: max_voltage_date {
    #   type: date
    #   sql: ${TABLE}."MAX_VOLTAGE_DATE" ;;
    # }

    # dimension: max_voltage {
    #   type: number
    #   sql: ${TABLE}."MAX_VOLTAGE" ;;
    # }

    # dimension: keypad_hardware {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_HARDWARE" ;;
    # }

    # dimension: keypad_app {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_APP" ;;
    # }

    # dimension: keypad_bootloader {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_BOOTLOADER" ;;
    # }

    # dimension: ecm_hardware {
    #   type: string
    #   sql: ${TABLE}."ECM_HARDWARE" ;;
    # }

    # dimension: ecm_app {
    #   type: string
    #   sql: ${TABLE}."ECM_APP" ;;
    # }

    # dimension: ecm_bootloader {
    #   type: string
    #   sql: ${TABLE}."ECM_BOOTLOADER" ;;
    # }

    # dimension: last_keypad_entry_date {
    #   type: string
    #   sql: ${TABLE}."LAST_KEYPAD_ENTRY_DATE" ;;
    # }

    # dimension_group: last_trip_date {
    #   type: time
    #   sql: ${TABLE}."LAST_TRIP_DATE" ;;
    # }

    # dimension: days_btwn_keypad_entry_and_trip {
    #   type: number
    #   sql: ${TABLE}."DAYS_BTWN_KEYPAD_ENTRY_AND_TRIP" ;;
    # }

    # dimension: keypad_vs_trip_health {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_VS_TRIP_HEALTH" ;;
    # }

    # dimension_group: last_keycode_assignment_date {
    #   type: time
    #   sql: ${TABLE}."LAST_KEYCODE_ASSIGNMENT_DATE" ;;
    # }

    # dimension: last_keycode_assignment_status {
    #   type: string
    #   sql: ${TABLE}."LAST_KEYCODE_ASSIGNMENT_STATUS" ;;
    # }

    # dimension: asset_health_status {
    #   type: string
    #   sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
    # }

    # dimension: tracker_req_type {
    #   type: string
    #   sql: ${TABLE}."TRACKER_REQ_TYPE" ;;
    # }

    # dimension: tracker_install_status {
    #   type: string
    #   sql: ${TABLE}."TRACKER_INSTALL_STATUS" ;;
    # }

    # dimension: keypad_id {
    #   type: number
    #   sql: ${TABLE}."KEYPAD_ID" ;;
    # }

    # dimension: keypad_serial {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_SERIAL" ;;
    # }

    # dimension: keypad_req {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_REQ" ;;
    # }

    # dimension: keypad_install_status {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_INSTALL_STATUS" ;;
    # }

    # dimension: keypad_req_type {
    #   type: string
    #   sql: ${TABLE}."KEYPAD_REQ_TYPE" ;;
    # }

    # dimension: camera_id {
    #   type: number
    #   sql: ${TABLE}."CAMERA_ID" ;;
    # }

    # dimension: camera_serial {
    #   type: string
    #   sql: ${TABLE}."CAMERA_SERIAL" ;;
    # }

    # dimension: camera_vendor {
    #   type: string
    #   sql: ${TABLE}."CAMERA_VENDOR" ;;
    # }

    # dimension: camera_req {
    #   type: string
    #   sql: ${TABLE}."CAMERA_REQ" ;;
    # }

    # dimension: camera_install_status {
    #   type: string
    #   sql: ${TABLE}."CAMERA_INSTALL_STATUS" ;;
    # }

    # dimension: camera_health {
    #   type: string
    #   sql: ${TABLE}."CAMERA_HEALTH" ;;
    # }

    # dimension_group: last_camera_heartbeat {
    #   type: time
    #   sql: ${TABLE}."LAST_CAMERA_HEARTBEAT" ;;
    # }

    # dimension: has_can {
    #   type: string
    #   sql: ${TABLE}."HAS_CAN" ;;
    # }

    # dimension: secondary_tracker_req {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_REQ" ;;
    # }

    # dimension: secondary_tracker_install_status {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_INSTALL_STATUS" ;;
    # }

    # dimension: secondary_tracker_id {
    #   type: number
    #   sql: ${TABLE}."SECONDARY_TRACKER_ID" ;;
    # }

    # dimension: secondary_tracker_serial {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_SERIAL" ;;
    # }

    # dimension: secondary_tracker_type {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_TYPE" ;;
    # }

    # dimension: secondary_tracker_vendor {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_VENDOR" ;;
    # }

    # dimension: secondary_tracker_last_checkin {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_LAST_CHECKIN" ;;
    # }

    # dimension: secondary_tracker_health_status {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_STATUS" ;;
    # }

    dimension: public_health_status {
      type: string
      sql: ${TABLE}."PUBLIC_HEALTH_STATUS" ;;
    }

    # dimension_group: last_delivery_date {
    #   type: time
    #   sql: ${TABLE}."LAST_DELIVERY_DATE" ;;
    # }

    # dimension: last_delivery_lat {
    #   type: number
    #   sql: ${TABLE}."LAST_DELIVERY_LAT" ;;
    # }

    # dimension: last_delivery_long {
    #   type: number
    #   sql: ${TABLE}."LAST_DELIVERY_LONG" ;;
    # }

    # dimension: last_delivery_drop_off_or_return {
    #   type: string
    #   sql: ${TABLE}."LAST_DELIVERY_DROP_OFF_OR_RETURN" ;;
    # }

    # dimension: last_delivery_contact_name {
    #   type: string
    #   sql: ${TABLE}."LAST_DELIVERY_CONTACT_NAME" ;;
    # }

    # dimension: last_delivery_contact_phone {
    #   type: string
    #   sql: ${TABLE}."LAST_DELIVERY_CONTACT_PHONE" ;;
    # }

    # dimension: last_delivery_address {
    #   type: string
    #   sql: ${TABLE}."LAST_DELIVERY_ADDRESS" ;;
    # }

    # dimension: tracker_model {
    #   type: string
    #   sql: ${TABLE}."TRACKER_MODEL" ;;
    # }

    # dimension: pending_keycode_count {
    #   type: number
    #   sql: ${TABLE}."PENDING_KEYCODE_COUNT" ;;
    # }

    # dimension: secondary_tracker_health_detail {
    #   type: string
    #   sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_DETAIL" ;;
    # }

    # dimension: category {
    #   type: string
    #   sql: ${TABLE}."CATEGORY" ;;
    # }

    # dimension: pending_keycode_aged_count {
    #   type: number
    #   sql: ${TABLE}."PENDING_KEYCODE_AGED_COUNT" ;;
    # }

    # dimension: battery_voltage_type {
    #   type: string
    #   sql: ${TABLE}."BATTERY_VOLTAGE_TYPE" ;;
    # }

    # dimension: rental_id {
    #   type: string
    #   sql: ${TABLE}."RENTAL_ID" ;;
    # }

    # dimension: renting_company_id {
    #   type: number
    #   sql: ${TABLE}."RENTING_COMPANY_ID" ;;
    # }

    # dimension: renting_company_name {
    #   type: string
    #   sql: ${TABLE}."RENTING_COMPANY_NAME" ;;
    # }

    # dimension: scheduled_off_rent_date {
    #   type: date
    #   sql: ${TABLE}."SCHEDULED_OFF_RENT_DATE" ;;
    # }

    dimension: is_reporting_ready {
      type: yesno
      sql: ${TABLE}."IS_REPORTING_READY" ;;
    }

    dimension_group: data_refresh_timestamp {
      type: time
      sql: ${TABLE}."DATA_REFRESH_TIMESTAMP" ;;
    }

  dimension: data_status {
    label: "Data Status"
    # type: string
    # sql:
    # CASE
    #   WHEN ${is_reporting_ready} = FALSE THEN '⚠️ Possible Issue'
    #   ELSE NULL
    # END ;;
    type: string
    sql: case when ${is_reporting_ready} = TRUE then 'Yes' else 'No' END ;;
    html:
    {% if value == 'Yes' %}
      <font color="#00CB86">✔</font> Up to Date
      {% else %}
      <font color="black">⚠️ Possible Data Delay</font>
      {% endif %}
    ;;
    group_label: "Quality Flag"
  }

    set: detail {
      fields: [
        asset_id,
        # custom_name,
        # serial_vin,
        # make,
        # model,
        # year,
        # asset_class,
        # asset_type,
        # asset_type_thr,
        # company_id,
        # company_name,
        # asset_inventory_status,
        # market_id,
        # market_name,
        # district,
        # region,
        # telematics_region,
        # ownership,
        # inventory_branch,
        # tracker_id,
        # tracker_serial,
        # device_serial,
        # tracker_type_id,
        # tracker_vendor,
        # tracker_type,
        # tracker,
        # phone_number,
        # tracker_last_date_installed_time,
        # latest_report_timestamp_time,
        # battery_voltage,
        # tracker_firmware_version,
        # ble_on_off,
        # geofences,
        # last_location,
        # is_ble_node,
        # unplugged,
        # street,
        # city,
        # state,
        # zip_code,
        # location,
        # last_checkin_timestamp_time,
        # asset_battery_voltage,
        # start_stale_gps_fix_timestamp,
        # last_location_timestamp_time,
        # latest_gps_fix_timestamp_time,
        # latest_satellites,
        # rssi,
        # rssi_timestamp_time,
        # last_cellular_contact_time,
        # hours,
        # lat,
        # long,
        # dead_battery,
        # asset_health_detail,
        # last_address,
        # max_voltage_date,
        # max_voltage,
        # keypad_hardware,
        # keypad_app,
        # keypad_bootloader,
        # ecm_hardware,
        # ecm_app,
        # ecm_bootloader,
        # last_keypad_entry_date,
        # last_trip_date_time,
        # days_btwn_keypad_entry_and_trip,
        # keypad_vs_trip_health,
        # last_keycode_assignment_date_time,
        # last_keycode_assignment_status,
        # asset_health_status,
        # tracker_req_type,
        # tracker_install_status,
        # keypad_id,
        # keypad_serial,
        # keypad_req,
        # keypad_install_status,
        # keypad_req_type,
        # camera_id,
        # camera_serial,
        # camera_vendor,
        # camera_req,
        # camera_install_status,
        # camera_health,
        # last_camera_heartbeat_time,
        # has_can,
        # secondary_tracker_req,
        # secondary_tracker_install_status,
        # secondary_tracker_id,
        # secondary_tracker_serial,
        # secondary_tracker_type,
        # secondary_tracker_vendor,
        # secondary_tracker_last_checkin,
        # secondary_tracker_health_status,
        public_health_status,
        # last_delivery_date_time,
        # last_delivery_lat,
        # last_delivery_long,
        # last_delivery_drop_off_or_return,
        # last_delivery_contact_name,
        # last_delivery_contact_phone,
        # last_delivery_address,
        # tracker_model,
        # pending_keycode_count,
        # secondary_tracker_health_detail,
        # category,
        # pending_keycode_aged_count,
        # battery_voltage_type,
        # rental_id,
        # renting_company_id,
        # renting_company_name,
        # scheduled_off_rent_date,
        is_reporting_ready,
        data_refresh_timestamp_time
      ]
    }
  }
