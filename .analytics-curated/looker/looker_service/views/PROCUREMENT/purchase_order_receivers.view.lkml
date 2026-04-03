view: purchase_order_receivers {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" ;;
  drill_fields: [purchase_order_receiver_id]

  dimension: purchase_order_receiver_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_received {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RECEIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: purchase_order_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: receiver_type {
    type: string
    sql: ${TABLE}."RECEIVER_TYPE" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [purchase_order_receiver_id, purchase_orders.purchase_order_id, purchase_order_receiver_items.count]
  }
  measure: count_distinct_receiver_id {
    label: "Number of Received Shipments"
    type: count_distinct
    sql: ${purchase_order_receiver_id} ;;
  }
}
