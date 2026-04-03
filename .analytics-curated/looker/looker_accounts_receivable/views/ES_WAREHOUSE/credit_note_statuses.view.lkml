view: credit_note_statuses {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."CREDIT_NOTE_STATUSES" ;;
  drill_fields: [credit_note_status_id]

  dimension: credit_note_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_STATUS_ID" ;;
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

  dimension: name {
    label: "Credit Note Status"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_status_id, name]
  }

}
