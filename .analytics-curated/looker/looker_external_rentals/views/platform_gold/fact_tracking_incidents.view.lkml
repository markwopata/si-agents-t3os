view: fact_tracking_incidents {
  sql_table_name: "PLATFORM"."GOLD"."V_TRACKING_INCIDENTS" ;;

  dimension: tracking_incident_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_KEY" ;;
    hidden: yes
  }

  dimension: tracking_incident_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
    value_format_name: id
  }

  dimension: tracking_incident_type_key {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_TYPE_KEY" ;;
    hidden: yes
  }

  dimension: tracking_incident_asset_key {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: tracking_incident_tracker_key {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_TRACKER_KEY" ;;
    hidden: yes
  }

  dimension: tracking_incident_geofence_key {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_GEOFENCE_KEY" ;;
    hidden: yes
  }

  dimension: tracking_incident_report_date_key {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_REPORT_DATE_KEY" ;;
    hidden: yes
  }

  dimension: tracking_incident_trip_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_TRIP_ID" ;;
    value_format_name: id
  }

  measure: tracking_incident_duration {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_DURATION" ;;
    value_format_name: decimal_2
  }

  dimension: tracking_incident_recordtimestamp {
    type: string
    sql: ${TABLE}."TRACKING_INCIDENT_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
