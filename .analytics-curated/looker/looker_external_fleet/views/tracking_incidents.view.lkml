view: tracking_incidents {
  sql_table_name: "PUBLIC"."TRACKING_INCIDENTS"
    ;;
  drill_fields: [tracking_incident_id]

  dimension: tracking_incident_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_ID" ;;
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

  dimension: asset_incident_threshold_id {
    type: number
    sql: ${TABLE}."ASSET_INCIDENT_THRESHOLD_ID" ;;
  }

  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }

  dimension: geofence_id {
    type: number
    sql: ${TABLE}."GEOFENCE_ID" ;;
  }

  dimension: incident_viewed {
    type: yesno
    sql: ${TABLE}."INCIDENT_VIEWED" ;;
  }

  dimension: optional_fields {
    type: string
    sql: ${TABLE}."OPTIONAL_FIELDS" ;;
  }

  dimension_group: report_timestamp {
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
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: time_fence_id {
    type: number
    sql: ${TABLE}."TIME_FENCE_ID" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: tracking_event_id {
    type: number
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
  }

  dimension: tracking_incident_type_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_TYPE_ID" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension_group: vendor_timestamp {
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
    sql: CAST(${TABLE}."VENDOR_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [tracking_incident_id]
  }
}
