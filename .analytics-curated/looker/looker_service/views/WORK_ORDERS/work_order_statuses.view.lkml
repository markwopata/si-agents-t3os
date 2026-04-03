view: work_order_statuses {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_STATUSES"
    ;;
  drill_fields: [work_order_status_id]

  dimension: work_order_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_STATUS_ID" ;;
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
    drill_fields: [work_order_status_id, name]
  }
}
