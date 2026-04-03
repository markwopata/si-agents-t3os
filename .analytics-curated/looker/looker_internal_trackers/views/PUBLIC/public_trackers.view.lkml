view: public_trackers {
  sql_table_name: "PUBLIC"."TRACKERS"
    ;;

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

  dimension: tracker_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRACKER_ID" ;;
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

  measure: count {
    type: count
    drill_fields: [trackers_trackers.tracker_id, company_id, device_serial, tracker_id, tracker_type_id, vendor_id]
  }

  measure: trackers_count {
    type: count_distinct
    sql: ${tracker_id} ;;
    drill_fields: [tracker_id]
  }
}
