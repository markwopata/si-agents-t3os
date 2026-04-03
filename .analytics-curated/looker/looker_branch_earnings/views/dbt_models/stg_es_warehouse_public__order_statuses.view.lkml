view: stg_es_warehouse_public__order_statuses {
  sql_table_name: "INTACCT_MODELS"."STG_ES_WAREHOUSE_PUBLIC__ORDER_STATUSES" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [name]
  }
}
