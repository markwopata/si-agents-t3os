view: fact_tracker_events {
  sql_table_name: "PLATFORM"."GOLD"."V_TRACKER_EVENTS" ;;

  dimension: tracker_events_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_KEY" ;;
    hidden: yes
  }

  dimension: tracker_events_slim_id {
    type: number
    sql: ${TABLE}."TRACKER_EVENTS_SLIM_ID" ;;
    value_format_name: id
  }

  dimension: tracker_events_event_type {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_EVENT_TYPE" ;;
  }

  dimension: tracker_events_asset_key {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: tracker_events_tracker_key {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_TRACKER_KEY" ;;
    hidden: yes
  }

  dimension: tracker_events_driver_user_key {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_DRIVER_USER_KEY" ;;
    hidden: yes
  }

  dimension: tracker_events_latest_report_date_key {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_LATEST_REPORT_DATE_KEY" ;;
    hidden: yes
  }

  measure: tracker_events_latitude {
    type: number
    sql: ${TABLE}."TRACKER_EVENTS_LATITUDE" ;;
    value_format_name: decimal_4
  }

  measure: tracker_events_longitude {
    type: number
    sql: ${TABLE}."TRACKER_EVENTS_LONGITUDE" ;;
    value_format_name: decimal_4
  }

  measure: tracker_events_odometer {
    type: number
    sql: ${TABLE}."TRACKER_EVENTS_ODOMETER" ;;
    value_format_name: decimal_2
  }

  dimension: tracker_events_recordtimestamp {
    type: string
    sql: ${TABLE}."TRACKER_EVENTS_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
