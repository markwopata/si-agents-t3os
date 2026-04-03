view: cameras {
  sql_table_name: "PUBLIC"."CAMERAS"
    ;;
  drill_fields: [vendor_camera_id]

  dimension: vendor_camera_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."VENDOR_CAMERA_ID" ;;
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

  dimension: camera_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CAMERA_ID" ;;
  }

  dimension: camera_vendor_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CAMERA_VENDOR_ID" ;;
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

  dimension: number_of_feeds {
    type: number
    sql: ${TABLE}."NUMBER_OF_FEEDS" ;;
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

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      vendor_camera_id,
      camera_vendors.name,
      camera_vendors.camera_vendor_id,
      cameras.vendor_camera_id,
      assets.count,
      cameras.count
    ]
  }
}
