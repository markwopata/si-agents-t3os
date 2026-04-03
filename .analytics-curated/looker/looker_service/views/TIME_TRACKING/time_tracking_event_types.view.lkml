view: time_tracking_event_types {
  sql_table_name: "ES_WAREHOUSE"."TIME_TRACKING"."TIME_TRACKING_EVENT_TYPES"
    ;;
  drill_fields: [time_tracking_event_type_id]

  dimension: time_tracking_event_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TIME_TRACKING_EVENT_TYPE_ID" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: label {
    type: string
    sql: ${TABLE}."LABEL" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [time_tracking_event_type_id, name]
  }
}
