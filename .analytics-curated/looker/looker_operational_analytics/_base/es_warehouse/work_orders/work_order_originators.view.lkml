view: work_order_originators {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_ORIGINATORS" ;;
  drill_fields: [work_order_originator_id]

  dimension: work_order_originator_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_ORIGINATOR_ID" ;;
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: originator_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ID" ;;
    value_format_name: id
  }
  dimension: originator_item_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ITEM_ID" ;;
    value_format_name: id
  }
  dimension: originator_item_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_ITEM_UUID" ;;
  }
  dimension: originator_type_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_TYPE_ID" ;;
    value_format_name: id
  }
  dimension: originator_uuid {
    type: string
    sql: ${TABLE}."ORIGINATOR_UUID" ;;
  }
  dimension: work_order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  work_order_originator_id,
  work_orders.work_order_type_name,
  work_orders.severity_level_name,
  work_orders.work_order_status_name,
  work_orders.urgency_level_name,
  work_orders.work_order_id
  ]
  }

}
