view: trips {
  sql_table_name: "PUBLIC"."TRIPS"
    ;;
  drill_fields: [hauling_trip_id]

  dimension: hauling_trip_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."HAULING_TRIP_ID" ;;
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

  dimension: aggressive_incidents {
    type: number
    sql: ${TABLE}."AGGRESSIVE_INCIDENTS" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_keypad_entry_id {
    type: number
    sql: ${TABLE}."ASSET_KEYPAD_ENTRY_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: driver_user_id {
    type: number
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }

  dimension: end_city {
    type: string
    sql: ${TABLE}."END_CITY" ;;
  }

  dimension: end_county {
    type: string
    sql: ${TABLE}."END_COUNTY" ;;
  }

  dimension: end_geofence_id {
    type: string
    sql: ${TABLE}."END_GEOFENCE_ID" ;;
  }

  dimension: end_hours {
    type: number
    sql: ${TABLE}."END_HOURS" ;;
  }

  dimension: end_lat {
    type: number
    sql: ${TABLE}."END_LAT" ;;
  }

  dimension: end_lon {
    type: number
    sql: ${TABLE}."END_LON" ;;
  }

  dimension: end_odometer {
    type: number
    sql: ${TABLE}."END_ODOMETER" ;;
  }

  dimension: end_state_abb {
    type: string
    sql: ${TABLE}."END_STATE_ABB" ;;
  }

  dimension: end_state_id {
    type: number
    sql: ${TABLE}."END_STATE_ID" ;;
  }

  dimension: end_street {
    type: string
    sql: ${TABLE}."END_STREET" ;;
  }

  dimension_group: end_timestamp {
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
    sql: CAST(${TABLE}."END_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_total_fuel_used_liters {
    type: number
    sql: ${TABLE}."END_TOTAL_FUEL_USED_LITERS" ;;
  }

  dimension: end_total_idle_fuel_used_liters {
    type: number
    value_format_name: id
    sql: ${TABLE}."END_TOTAL_IDLE_FUEL_USED_LITERS" ;;
  }

  dimension: end_total_idle_seconds {
    type: number
    value_format_name: id
    sql: ${TABLE}."END_TOTAL_IDLE_SECONDS" ;;
  }

  dimension: end_trip_time_id {
    type: number
    sql: ${TABLE}."END_TRIP_TIME_ID" ;;
  }

  dimension: hauling_asset_id {
    type: number
    sql: ${TABLE}."HAULING_ASSET_ID" ;;
  }

  dimension: idle_duration {
    type: number
    sql: ${TABLE}."IDLE_DURATION" ;;
  }

  dimension: idle_incidents {
    type: number
    sql: ${TABLE}."IDLE_INCIDENTS" ;;
  }

  dimension: impact_incidents {
    type: number
    sql: ${TABLE}."IMPACT_INCIDENTS" ;;
  }

  dimension: speeding_duration {
    type: number
    sql: ${TABLE}."SPEEDING_DURATION" ;;
  }

  dimension: speeding_incidents {
    type: number
    sql: ${TABLE}."SPEEDING_INCIDENTS" ;;
  }

  dimension: start_city {
    type: string
    sql: ${TABLE}."START_CITY" ;;
  }

  dimension: start_county {
    type: string
    sql: ${TABLE}."START_COUNTY" ;;
  }

  dimension: start_geofence_id {
    type: string
    sql: ${TABLE}."START_GEOFENCE_ID" ;;
  }

  dimension: start_hours {
    type: number
    sql: ${TABLE}."START_HOURS" ;;
  }

  dimension: start_lat {
    type: number
    sql: ${TABLE}."START_LAT" ;;
  }

  dimension: start_lon {
    type: number
    sql: ${TABLE}."START_LON" ;;
  }

  dimension: start_odometer {
    type: number
    sql: ${TABLE}."START_ODOMETER" ;;
  }

  dimension: start_state_abb {
    type: string
    sql: ${TABLE}."START_STATE_ABB" ;;
  }

  dimension: start_state_id {
    type: number
    sql: ${TABLE}."START_STATE_ID" ;;
  }

  dimension: start_street {
    type: string
    sql: ${TABLE}."START_STREET" ;;
  }

  dimension_group: start_timestamp {
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
    sql: CAST(${TABLE}."START_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: start_total_fuel_used_liters {
    type: number
    sql: ${TABLE}."START_TOTAL_FUEL_USED_LITERS" ;;
  }

  dimension: start_total_idle_fuel_used_liters {
    type: number
    value_format_name: id
    sql: ${TABLE}."START_TOTAL_IDLE_FUEL_USED_LITERS" ;;
  }

  dimension: start_total_idle_seconds {
    type: number
    value_format_name: id
    sql: ${TABLE}."START_TOTAL_IDLE_SECONDS" ;;
  }

  dimension: start_trip_time_id {
    type: number
    sql: ${TABLE}."START_TRIP_TIME_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }

  dimension: trip_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: trip_time_seconds {
    type: number
    sql: ${TABLE}."TRIP_TIME_SECONDS" ;;
  }

  dimension: trip_type_id {
    type: number
    sql: ${TABLE}."TRIP_TYPE_ID" ;;
  }

  measure: total_hours_unplugged {
    type: count_distinct
    sql: (TIMESTAMPDIFF('Hour',${start_timestamp_raw},${end_timestamp_raw})) ;;
  }

  measure: count {
    type: count
    drill_fields: [hauling_trip_id, trips.hauling_trip_id, trips.count]
  }
}
