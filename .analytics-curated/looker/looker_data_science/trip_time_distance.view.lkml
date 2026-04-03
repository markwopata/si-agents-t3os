view: trip_time_distance {
  sql_table_name: "MVW_TRIP_TIME_DISTANCE"
  ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: device_serial {
    type: number
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: end_timestamp {
    type: date_time
    sql: ${TABLE}."END_TIMESTAMP" ;;
  }

  dimension: trip_time_seconds {
    type: number
    sql: ${TABLE}."TRIP_TIME_SECONDS" ;;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

}
