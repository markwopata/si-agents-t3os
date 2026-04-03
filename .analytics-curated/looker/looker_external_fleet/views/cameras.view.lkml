view: cameras {
  sql_table_name: "PUBLIC"."CAMERAS"
    ;;
  drill_fields: [camera_id]

  dimension: camera_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CAMERA_ID" ;;
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

  dimension: camera_vendor_id {
    type: number
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
    label: "Camera Serial"
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

  dimension: vendor_camera_id {
    type: string
    sql: ${TABLE}."VENDOR_CAMERA_ID" ;;
  }

  measure: count {
    label: " Count"
    type: count_distinct
    sql: ${assets.asset_id} ;;
    drill_fields: [assets.custom_name, assets.make, assets.model, assets.ownership_type, asset_types.asset_types, categories.name, device_serial, asset_last_location.location_address]
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${count} ;;
  }

  # measure: distinct_asset_id_count {
  #   type: count_distinct
  #   label: "  Count"
  #   sql: ${asset_id} ;;

  # }

  dimension: asset_to_camera {
    type: string
    sql: case when ${camera_id} is null then 'No Camera' else 'Has Camera' end ;;
  }

}
