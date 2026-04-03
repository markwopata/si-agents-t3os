view: asset_last_location {
  sql_table_name: "PUBLIC"."ASSET_LAST_LOCATION"
    ;;

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: geofences {
    type: string
    sql: ${TABLE}."GEOFENCES" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension_group: last_location_timestamp {
    type: time
    sql: ${TABLE}."LAST_LOCATION_TIMESTAMP" ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    sql: ${TABLE}."LAST_CHECKIN_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  dimension: last_location {
    type: string
    sql: coalesce(${geofences},${address},${location}) ;;
  }
}
