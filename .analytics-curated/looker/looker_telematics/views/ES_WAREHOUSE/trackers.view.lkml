view: trackers {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."TRACKERS"
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: battery_voltage_type_id {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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
    sql: CAST(${TABLE}."CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: phone_number {
    type: string
    sql: ${TABLE}."PHONE_NUMBER" ;;
  }

  dimension: tracker_type_id {
    type: number
    sql: ${TABLE}."TRACKER_TYPE_ID" ;;
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
    sql: CAST(${TABLE}."UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: serial_with_trackers_manager_link {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
    link: {
      label: "Trackers Manager"
      url: "https://tracker-manager.equipmentshare.com/#/trackers/search?trackers={{ value | url_encode }}"
    }
    description: "This links out to the Trackers Manager Platform"
  }

  measure: count {
    type: count
    drill_fields: [serial_with_trackers_manager_link, trackers_mapping.asset_id, trackers_mapping.asset_name, trackers_mapping.tracker_tracker_id, trackers_mapping.esdb_tracker_id]
  }

}
