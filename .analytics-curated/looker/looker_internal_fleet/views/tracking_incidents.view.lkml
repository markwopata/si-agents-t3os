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

  measure: tracking_incident_timestamp {
    type: date_time
    sql: MAX(${report_timestamp_raw}) ;;
    convert_tz: no
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

  dimension: latest_tracking_event_id {
    type: number
    sql: ${tracking_event_id} in (select max(${tracking_event_id}) from tracking_incidents group by ${asset_id}) ;;
  }

  dimension: tracking_incident_type_id {
    type: number
    sql: ${TABLE}."TRACKING_INCIDENT_TYPE_ID" ;;
  }

  dimension: only_intalls_or_unplugs {
    type: yesno
    sql: case when ${tracking_incident_type_id} = '9' then 'YES'
              when ${tracking_incident_type_id} = '10' then 'YES'
              ELSE ' ' END;;
  }

  dimension: install_or_unplug {
    type: string
    sql: case when ${tracking_incident_type_id} = '9' then 'Install'
          when ${tracking_incident_type_id} = '10' then 'Unplug'
          else ' ' end ;;
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

  measure: tracker_unplugs {
    type: count
#    sql: ${TABLE}."tracking_incident_type_id" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Set Field for Drilling -----
  set: detail {
    fields: [
      asset_id,
      tracking_incident_id,
      tracker_id
    ]
  }
}
