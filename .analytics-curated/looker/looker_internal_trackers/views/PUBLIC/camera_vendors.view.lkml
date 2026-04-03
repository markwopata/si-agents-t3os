view: camera_vendors {
  sql_table_name: "PUBLIC"."CAMERA_VENDORS"
    ;;
  drill_fields: [camera_vendor_id]

  dimension: camera_vendor_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CAMERA_VENDOR_ID" ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [camera_vendor_id, name, cameras.count]
  }
}
