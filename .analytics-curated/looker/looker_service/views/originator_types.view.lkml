view: originator_types {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."ORIGINATOR_TYPES" ;;
  drill_fields: [originator_type_id]

  dimension: originator_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORIGINATOR_TYPE_ID" ;;
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
    drill_fields: [originator_type_id, name]
  }
}
