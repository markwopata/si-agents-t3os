view: asset_settings {
  sql_table_name: "PUBLIC"."ASSET_SETTINGS"
    ;;
  drill_fields: [asset_settings_id]

  dimension: asset_settings_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_SETTINGS_ID" ;;
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

  dimension: alert_enter_geofence {
    type: yesno
    sql: ${TABLE}."ALERT_ENTER_GEOFENCE" ;;
  }

  dimension: alert_exit_geofence {
    type: yesno
    sql: ${TABLE}."ALERT_EXIT_GEOFENCE" ;;
  }

  dimension: alert_time_fence {
    type: yesno
    sql: ${TABLE}."ALERT_TIME_FENCE" ;;
  }

  dimension: idling {
    type: yesno
    sql: ${TABLE}."IDLING" ;;
  }

  dimension: ifta_reporting {
    type: yesno
    sql: ${TABLE}."IFTA_REPORTING" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_settings_id]
  }
}
