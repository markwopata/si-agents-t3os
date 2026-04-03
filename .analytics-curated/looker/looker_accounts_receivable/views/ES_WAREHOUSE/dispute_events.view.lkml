view: dispute_events {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DISPUTE_EVENTS" ;;
  drill_fields: [dispute_event_id]

  dimension: dispute_event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DISPUTE_EVENT_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }
  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: dispute_credit_reason_id {
    type: number
    sql: ${TABLE}."DISPUTE_CREDIT_REASON_ID" ;;
  }
  dimension: dispute_event_type_id {
    type: number
    sql: ${TABLE}."DISPUTE_EVENT_TYPE_ID" ;;
  }
  dimension: dispute_id {
    type: number
    sql: ${TABLE}."DISPUTE_ID" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  measure: count {
    type: count
    drill_fields: [dispute_event_id]
  }
}
