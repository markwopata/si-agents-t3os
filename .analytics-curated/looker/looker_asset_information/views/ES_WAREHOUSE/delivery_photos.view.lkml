view: delivery_photos {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DELIVERY_PHOTOS"
    ;;
  drill_fields: [delivery_photo_id]

  dimension: delivery_photo_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DELIVERY_PHOTO_ID" ;;
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

  dimension: delivery_id {
    type: number
    sql: ${TABLE}."DELIVERY_ID" ;;
  }

  dimension: photo_id {
    type: number
    sql: ${TABLE}."PHOTO_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [delivery_photo_id]
  }
}
