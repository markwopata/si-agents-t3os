view: credit_note_types {
  sql_table_name: "PUBLIC"."CREDIT_NOTE_TYPES"
    ;;
  drill_fields: [credit_note_type_id]

  dimension: credit_note_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CREDIT_NOTE_TYPE_ID" ;;
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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [credit_note_type_id, name, credit_notes.count]
  }
}
