view: purchase_order_receiver_items {
  sql_table_name: "PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ;;
  drill_fields: [purchase_order_receiver_item_id]

  dimension: purchase_order_receiver_item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ITEM_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."ACCEPTED_QUANTITY" ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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
  dimension: packinglist_quantity {
    type: number
    sql: ${TABLE}."PACKINGLIST_QUANTITY" ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }
  dimension: purchase_order_line_item_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }
  dimension: purchase_order_receiver_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ID" ;;
  }
  dimension: rejected_quantity {
    type: number
    sql: ${TABLE}."REJECTED_QUANTITY" ;;
  }
  measure: count {
    type: count
    drill_fields: [purchase_order_receiver_item_id, purchase_order_line_items.purchase_order_line_item_id, purchase_order_receivers.purchase_order_receiver_id]
  }
}
