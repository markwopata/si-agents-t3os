view: can_snapshot_data_spn {
  sql_table_name: "PUBLIC"."CAN_SNAPSHOT_DATA_SPN"
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: can_id {
    type: string
    sql: ${TABLE}."CAN_ID" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: pgn {
    type: number
    sql: ${TABLE}."pgn" ;;
  }

  dimension: spn {
    type: number
    sql: ${TABLE}."spn" ;;
  }


  measure: count {
    type: count
    drill_fields: []
  }

}
