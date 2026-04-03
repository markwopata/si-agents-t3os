view: asset_geofence_encounters {
  sql_table_name: "PUBLIC"."ASSET_GEOFENCE_ENCOUNTERS"
    ;;
  drill_fields: [asset_geofence_encounter_id]

  dimension: asset_geofence_encounter_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_GEOFENCE_ENCOUNTER_ID" ;;
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: encounter_time_range {
    type: string
    sql: ${TABLE}."ENCOUNTER_TIME_RANGE" ;;
  }

  dimension: end_hours {
    type: number
    sql: ${TABLE}."END_HOURS" ;;
  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
  }

  dimension: end_location_geo {
    type: string
    sql: ${TABLE}."END_LOCATION_GEO" ;;
  }

  dimension: end_location_old {
    type: string
    sql: ${TABLE}."END_LOCATION_OLD" ;;
  }

  dimension: end_odometer {
    type: number
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: end_tracking_event_id {
    type: number
    sql: ${TABLE}."END_TRACKING_EVENT_ID" ;;
  }

  dimension: geofence_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: start_hours {
    type: number
    sql: ${TABLE}."START_HOURS" ;;
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
  }

  dimension: start_location_geo {
    type: string
    sql: ${TABLE}."START_LOCATION_GEO" ;;
  }

  dimension: start_location_old {
    type: string
    sql: ${TABLE}."START_LOCATION_OLD" ;;
  }

  dimension: start_odometer {
    type: number
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: start_tracking_event_id {
    type: number
    sql: ${TABLE}."START_TRACKING_EVENT_ID" ;;
  }

  dimension_group: start_range {
    type: time
    timeframes: [time,date,week,month,year]
    sql: ${TABLE}."ENCOUNTER_START_TIMESTAMP" ;;
  }

  dimension_group: end_range {
    type: time
    timeframes: [time,date,week,month,year]
    sql: ${TABLE}."ENCOUNTER_END_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_geofence_encounter_id, geofences.name, geofences.geofence_id]
  }
}
