view: stg_t3__telematics_health {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__TELEMATICS_HEALTH" ;;

  dimension: asset_battery_voltage {
    type: number
    sql: ${TABLE}."ASSET_BATTERY_VOLTAGE" ;;
  }
  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }
  dimension: asset_health_detail {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_DETAIL" ;;
  }
  dimension: asset_health_status {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
  }
  dimension: asset_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension: asset_type_thr {
    type: string
    sql: ${TABLE}."ASSET_TYPE_THR" ;;
  }
  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }
  dimension: battery_voltage_type {
    type: string
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE" ;;
  }
  dimension: ble_on_off {
    type: string
    sql: ${TABLE}."BLE_ON_OFF" ;;
  }
  dimension: camera_health {
    type: string
    sql: ${TABLE}."CAMERA_HEALTH" ;;
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
    sql: ${TABLE}."CAMERA_SERIAL" ;;
  }
  dimension: camera_vendor {
    type: string
    sql: ${TABLE}."CAMERA_VENDOR" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
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
  dimension: days_btwn_keypad_entry_and_trip {
    type: number
    sql: ${TABLE}."DAYS_BTWN_KEYPAD_ENTRY_AND_TRIP" ;;
  }
  dimension: dead_battery {
    type: string
    sql: ${TABLE}."DEAD_BATTERY" ;;
  }
  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
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
  dimension: inventory_branch {
    type: string
    sql: ${TABLE}."INVENTORY_BRANCH" ;;
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
    sql: ${TABLE}."KEYPAD_SERIAL" ;;
  }
  dimension: keypad_vs_trip_health {
    type: string
    sql: ${TABLE}."KEYPAD_VS_TRIP_HEALTH" ;;
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
  dimension: last_checkin_timestamp {
    type: string
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }
  dimension: last_delivery_address {
    type: string
    sql: ${TABLE}."LAST_DELIVERY_ADDRESS" ;;
  }
  dimension: last_delivery_contact_name {
    type: string
    sql: ${TABLE}."LAST_DELIVERY_CONTACT_NAME" ;;
  }
  dimension: last_delivery_contact_phone {
    type: string
    sql: ${TABLE}."LAST_DELIVERY_CONTACT_PHONE" ;;
  }
  dimension_group: last_delivery {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_DELIVERY_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: last_delivery_drop_off_or_return {
    type: string
    sql: ${TABLE}."LAST_DELIVERY_DROP_OFF_OR_RETURN" ;;
  }
  dimension: last_delivery_lat {
    type: number
    sql: ${TABLE}."LAST_DELIVERY_LAT" ;;
  }
  dimension: last_delivery_long {
    type: number
    sql: ${TABLE}."LAST_DELIVERY_LONG" ;;
  }
  dimension_group: last_keycode_assignment {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_KEYCODE_ASSIGNMENT_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: last_keycode_assignment_status {
    type: string
    sql: ${TABLE}."LAST_KEYCODE_ASSIGNMENT_STATUS" ;;
  }
  dimension: last_keypad_entry_date {
    type: string
    sql: ${TABLE}."LAST_KEYPAD_ENTRY_DATE" ;;
  }
  dimension: last_location {
    type: string
    sql: ${TABLE}."LAST_LOCATION" ;;
  }
  dimension: last_location_timestamp {
    type: string
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }
  dimension_group: last_trip {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."LAST_TRIP_DATE" AS TIMESTAMP_NTZ) ;;
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
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
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
  dimension: pending_keycode_aged_count {
    type: number
    sql: ${TABLE}."PENDING_KEYCODE_AGED_COUNT" ;;
  }
  dimension: pending_keycode_count {
    type: number
    sql: ${TABLE}."PENDING_KEYCODE_COUNT" ;;
  }
  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }
  dimension: public_health_status {
    label: "Tracker Health Status"
    type: string
    sql: ${TABLE}."PUBLIC_HEALTH_STATUS" ;;
  }
  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: rssi {
    type: string
    sql: ${TABLE}."RSSI" ;;
  }
  dimension_group: rssi_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."RSSI_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: secondary_tracker_health_detail {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_DETAIL" ;;
  }
  dimension: secondary_tracker_health_status {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_HEALTH_STATUS" ;;
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
  dimension: secondary_tracker_req {
    type: string
    sql: ${TABLE}."SECONDARY_TRACKER_REQ" ;;
  }
  dimension: secondary_tracker_serial {
    type: string
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
    sql: ${TABLE}."SERIAL_VIN" ;;
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
  dimension: tracker_model {
    type: string
    sql: ${TABLE}."TRACKER_MODEL" ;;
  }
  dimension: tracker_req_type {
    type: string
    sql: ${TABLE}."TRACKER_REQ_TYPE" ;;
  }
  dimension: tracker_serial {
    type: string
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
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }
  measure: count {
    type: count
    drill_fields: [asset_custom_name_to_asset_info, make, model, tracker, public_health_status, last_checkin_date, lastest_gps_date]
  }

  dimension: tracker_install_date {
    group_label: "HTML Formatted Time"
    label: "Tracker Install Date"
    type: date
    sql: ${tracker_last_date_installed_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: last_checkin_date {
    group_label: "HTML Formatted Time"
    label: "Last Checkin Time"
    type: date_time
    sql: ${last_checkin_timestamp} ;;
    # html: {{ rendered_value | date: "%b %d, %Y"  }};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: lastest_gps_date {
    group_label: "HTML Formatted Time"
    label: "Latest GPS Time"
    type: date_time
    sql: ${latest_gps_fix_timestamp_raw} ;;
    # html: {{ rendered_value | date: "%b %d, %Y"  }};;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  dimension: health_status {
    type: string
    sql: ${public_health_status} ;;
    html: {% if value == 'HEALTHY' %}

    <span style="color: #00CB86;">◉ </span>{{rendered_value}}

    {% elsif value == 'NEEDS ASSET ATTENTION' %}

    <span style="color: #d47376;">◉ </span>{{rendered_value}}

    {% elsif value == 'NEEDS TRACKER ATTENTION' %}

    <span style="color: #FFBF00;">◉ </span>{{rendered_value}}

    {% elsif value == 'INACTIVE' %}

    <span style="color: #8C8C8C;">◉ </span>{{rendered_value}}

    {% elsif value == 'UNSTABLE' %}

    <span style="color: #DCDCDC;">◉ </span>{{rendered_value}}

    {% elsif value == 'NO TRACKER' %}

    <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

    {% else %}

    {{rendered_value}}

    {% endif %};;
  }

  measure: total_assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }

  dimension: asset_custom_name_to_asset_info {
    group_label: "Link to T3"
    label: "Asset"
    type: string
    sql: ${custom_name};;
    html: <font color="#0063f3"><u><a href="https://app.estrack.com/#/assets/all/asset/{{ asset_id._filterable_value }}/status" target="_blank">{{value}}</a></font></u>;;
  }

  dimension: health_detail {
    label: "Tracker Health Status"
    type: string
    sql: ${public_health_status} ;;
    html: {% if value == 'Healthy' %}

          <span style="color: #00ad73;">◉ </span>{{rendered_value}}

      {% elsif value == 'Asset Likely Under Cover or Inside Building' %}

      <span style="color: #70d9a5;">◉ </span>{{rendered_value}}

      {% elsif value == 'Asset Likely In Low Cell Coverage Area' %}

      <span style="color: #c1ecd4;">◉ </span>{{rendered_value}}

      {% elsif value == 'Dead Asset Battery' %}

      <span style="color: #e55c66;">◉ </span>{{rendered_value}}

      {% elsif value == 'Drained Asset Battery' %}

      <span style="color: #FFB14E;">◉ </span>{{rendered_value}}

      {% elsif value == 'Master Cutoff Switch/Tracker Disconnected' %}

      <span style="color: #fcdd6a;">◉ </span>{{rendered_value}}

      {% elsif value == 'Needs Tracker Attention' %}

      <span style="color: #b02a3e;">◉ </span>{{rendered_value}}

      {% else %}

      {{rendered_value}}

      {% endif %};;
  }

  dimension: overall_health_buckets {
    type: string
    sql: case when ${public_health_status} in ('Healthy','Asset Likely In Low Cell Coverage Area','Asset Likely Under Cover or Inside Building') then 'Healthy'
    when ${public_health_status} in ('Dead Asset Battery','Drained Asset Battery','Master Cutoff Switch/Tracker Disconnected') then 'Needs Asset Attention'
    when ${public_health_status} in ('No Tracker Installed') then 'No Tracker'
    when ${public_health_status} in ('Needs Tracker Attention') then 'Needs Tracker Attention'
    else 'Undefined'
    end
    ;;
    link: {
      label: "View Tracker Details"
      icon_url: "https://imgur.com/ZCNurvk.png"
      url: "{% assign vis = '{
  \"type\": \"looker_column\",
  \"show_legend\": true,
  \"legend_position\": \"bottom\",
  \"stacking\": \"normal\",
  \"hidden_series\": [],
  \"series_labels\": {},
  \"defaults_version\": 1
}' %}

{{ dummy._link }}&vis={{ vis | encode_uri }}"
    }
  }
  measure: dummy {
    hidden: yes
    type: number
    sql: 0 ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      asset_custom_name_to_asset_info,
      make,
      model,
      tracker,
      health_detail,
      last_checkin_date,
      lastest_gps_date
    ]
  }
}
