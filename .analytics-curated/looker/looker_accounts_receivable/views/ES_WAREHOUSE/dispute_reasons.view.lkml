view: dispute_reasons {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."DISPUTE_REASONS" ;;
  drill_fields: [dispute_reason_id]

  dimension: dispute_reason_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."DISPUTE_REASON_ID" ;;
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
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  measure: count {
    type: count
    drill_fields: [dispute_reason_id]
  }
  measure: dispute_reasons {
    type: list
    list_field: description
  }
}
