view: urgency_levels {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."URGENCY_LEVELS" ;;
  drill_fields: [urgency_level_id]

  dimension: urgency_level_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."URGENCY_LEVEL_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [urgency_level_id, name]
  }
}
