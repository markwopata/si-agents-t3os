view: trackers {
  sql_table_name: "PUBLIC"."TRACKERS"
    ;;
  drill_fields: [tracker_id]

  dimension: tracker_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    hidden: yes
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
    hidden: yes
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
    hidden: yes
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
    hidden: yes
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
    hidden: yes
  }

  dimension: tracker_information {
    type: string
    sql: coalesce(concat(coalesce(${tracker_types.name},'Unknown Tracker Name'),': ',${device_serial}),'No Tracker') ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_id]
  }
}
