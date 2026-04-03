view: reservation_target_types {
  sql_table_name: "INVENTORY"."INVENTORY"."RESERVATION_TARGET_TYPES" ;;
  drill_fields: [reservation_target_type_id, name]

  dimension: reservation_target_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RESERVATION_TARGET_TYPE_ID" ;;
    value_format: "0"
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [reservation_target_type_id, name]
  }
}
