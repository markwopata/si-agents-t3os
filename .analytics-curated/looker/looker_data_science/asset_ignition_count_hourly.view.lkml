view: asset_ignition_count_hourly {
  sql_table_name: "PUBLIC"."ASSET_IGNITION_COUNT_HOURLY"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: avg_ignition_onoff_per_hour {
    type: number
    sql: ${TABLE}."AVG_IGNITION_ONOFF_PER_HOUR" ;;
  }

  dimension: device_serial {
    type: string
    sql: ${TABLE}."DEVICE_SERIAL" ;;
  }

  dimension: max_ignition_onoff_per_hour {
    type: number
    sql: ${TABLE}."MAX_IGNITION_ONOFF_PER_HOUR" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
