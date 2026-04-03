view: fact_custom_trips {
  sql_table_name: "PLATFORM"."GOLD"."V_CUSTOM_TRIPS" ;;

  dimension: custom_trips_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_KEY" ;;
    hidden: yes
  }

  dimension: custom_trips_asset_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: custom_trips_tracker_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_TRACKER_KEY" ;;
    hidden: yes
  }

  dimension: custom_trips_enter_date_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_ENTER_DATE_KEY" ;;
    hidden: yes
  }

  dimension: custom_trips_exit_date_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_EXIT_DATE_KEY" ;;
    hidden: yes
  }

  dimension: custom_trips_state_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_STATE_KEY" ;;
    hidden: yes
  }

  dimension: custom_trips_geofence_key {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_GEOFENCE_KEY" ;;
    hidden: yes
  }

  measure: custom_trips_enter_odometer {
    type: number
    sql: ${TABLE}."CUSTOM_TRIPS_ENTER_ODOMETER" ;;
    value_format_name: decimal_2
  }

  measure: custom_trips_exit_odometer {
    type: number
    sql: ${TABLE}."CUSTOM_TRIPS_EXIT_ODOMETER" ;;
    value_format_name: decimal_2
  }

  dimension: custom_trips_recordtimestamp {
    type: string
    sql: ${TABLE}."CUSTOM_TRIPS_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
