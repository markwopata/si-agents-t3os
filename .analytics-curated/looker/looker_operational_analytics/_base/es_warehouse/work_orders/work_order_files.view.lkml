view: work_order_files {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_FILES" ;;
  drill_fields: [work_order_file_id]

  dimension: work_order_file_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_FILE_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: metadata_id {
    type: number
    sql: ${TABLE}."METADATA_ID" ;;
  }
  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [work_order_file_id]
  }
}
