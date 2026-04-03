
view: purchase_order_line_items {
  sql_table_name: procurement.public__silver.purchase_order_line_items;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_line_item_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
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
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: item_id {
    type: string
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
    value_format_name: usd_0
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  measure: quantity_sum {
    label: "Total Items"
    type: sum
    sql: ${quantity} ;;
  }

  measure: total_po_cost {
    type: sum
    sql: ${quantity} * ${price_per_unit} ;;
    value_format_name: usd_0
  }

  dimension: total_accepted {
    type: number
    sql: ${TABLE}."TOTAL_ACCEPTED" ;;
  }

  dimension: total_rejected {
    type: number
    sql: ${TABLE}."TOTAL_REJECTED" ;;
  }

  dimension_group: _purchase_order_line_items_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_LINE_ITEMS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _purchase_order_line_items_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_LINE_ITEMS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        purchase_order_line_item_id,
  allocation_id,
  allocation_snapshot_id,
  allocation_type,
  date_archived_time,
  description,
  item_id,
  item_snapshot_id,
  memo,
  price_per_unit,
  purchase_order_id,
  quantity,
  total_accepted,
  total_rejected,
  _purchase_order_line_items_effective_start_utc_datetime_time,
  _purchase_order_line_items_effective_delete_utc_datetime_time
    ]
  }
}
