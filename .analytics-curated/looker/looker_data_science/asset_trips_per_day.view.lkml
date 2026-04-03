view: asset_trips_per_day {
  sql_table_name: "PUBLIC"."ASSET_TRIPS_PER_DAY"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: avg_day_trips_count {
    type: number
    sql: ${TABLE}."AVG_DAY_TRIPS_COUNT" ;;
  }

  dimension: max_day_trips_count {
    type: number
    sql: ${TABLE}."MAX_DAY_TRIPS_COUNT" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
