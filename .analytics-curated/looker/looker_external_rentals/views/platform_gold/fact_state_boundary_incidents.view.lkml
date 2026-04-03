view: fact_state_boundary_incidents {
  sql_table_name: "PLATFORM"."GOLD"."V_STATE_BOUNDARY_INCIDENTS" ;;

  dimension: state_boundary_incidents_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_KEY" ;;
    hidden: yes
  }

  dimension: state_boundary_incidents_id {
    type: number
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_ID" ;;
    value_format_name: id
  }

  dimension: state_boundary_incidents_incident_type {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_INCIDENT_TYPE" ;;
  }

  dimension: state_boundary_incidents_asset_key {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_ASSET_KEY" ;;
    description: "FK to dim_assets"
  }

  dimension: state_boundary_incidents_tracker_key {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_TRACKER_KEY" ;;
    hidden: yes
  }

  dimension: state_boundary_incidents_date_key {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_DATE_KEY" ;;
    hidden: yes
  }

  dimension: state_boundary_incidents_geofence_key {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_GEOFENCE_KEY" ;;
    hidden: yes
  }

  dimension: state_boundary_incidents_recordtimestamp {
    type: string
    sql: ${TABLE}."STATE_BOUNDARY_INCIDENTS_RECORDTIMESTAMP" ;;
    description: "Record timestamp (ETL)"
    value_format_name: id
    hidden: yes
  }
}
