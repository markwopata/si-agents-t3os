view: fact_trips_legacy {
  sql_table_name: "PLATFORM"."GOLD"."V_TRIPS_LEGACY" ;;

  dimension: trips_legacy_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_KEY" ;;
    hidden: yes
  }

  dimension: trips_legacy_trip_id {
    type: number
    sql: ${TABLE}."TRIPS_LEGACY_TRIP_ID" ;;
    value_format_name: id
  }

  dimension: trips_legacy_asset_key {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: trips_legacy_tracker_key {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_TRACKER_KEY" ;;
    hidden: yes
  }

  dimension: trips_legacy_driver_user_key {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_DRIVER_USER_KEY" ;;
    hidden: yes
  }

  dimension: trips_legacy_start_timestamp_date_key {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_START_TIMESTAMP_DATE_KEY" ;;
    hidden: yes
  }

  dimension: trips_legacy_end_timestamp_date_key {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_END_TIMESTAMP_DATE_KEY" ;;
    hidden: yes
  }

  measure: trips_legacy_distance_miles {
    type: number
    sql: ${TABLE}."TRIPS_LEGACY_DISTANCE_MILES" ;;
    value_format_name: decimal_2
  }

  measure: trips_legacy_time_seconds {
    type: number
    sql: ${TABLE}."TRIPS_LEGACY_TIME_SECONDS" ;;
    value_format_name: id
  }

  measure: trips_legacy_total_hours {
    type: number
    sql: ${TABLE}."TRIPS_LEGACY_TOTAL_HOURS" ;;
    value_format_name: decimal_2
  }

  dimension: trips_legacy_recordtimestamp {
    type: string
    sql: ${TABLE}."TRIPS_LEGACY_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
