view: credit_note_history {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CREDIT_NOTE_HISTORY" ;;
  drill_fields: [credit_note_history_id]

  dimension: credit_note_history_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_HISTORY_ID" ;;
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
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: credit_note_allocation_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ALLOCATION_ID" ;;
  }
  dimension: credit_note_history_event_type_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_HISTORY_EVENT_TYPE_ID" ;;
  }
  dimension: credit_note_id {
    type: number
    sql: ${TABLE}."CREDIT_NOTE_ID" ;;
  }
  dimension_group: event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EVENT_DATE" ;;
  }
  dimension_group: posting {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."POSTING_DATE" ;;
  }
  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [credit_note_history_id]
  }
}
