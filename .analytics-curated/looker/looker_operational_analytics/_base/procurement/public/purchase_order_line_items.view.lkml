view: purchase_order_line_items {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" ;;
  drill_fields: [purchase_order_line_item_id]

  dimension: purchase_order_line_item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: allocation_id {
    type: string
    sql: ${TABLE}."ALLOCATION_ID" ;;
  }
  dimension: allocation_snapshot_id {
    type: string
    sql: ${TABLE}."ALLOCATION_SNAPSHOT_ID" ;;
  }
  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: item_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: item_snapshot_id {
    type: string
    sql: ${TABLE}."ITEM_SNAPSHOT_ID" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format_name: usd
  }
  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: total_accepted {
    type: number
    sql: ${TABLE}."TOTAL_ACCEPTED" ;;
  }
  dimension: total_rejected {
    type: number
    sql: ${TABLE}."TOTAL_REJECTED" ;;
  }
  measure: count {
    type: count
    drill_fields: [purchase_order_line_item_id, items.item_id]
  }
}
