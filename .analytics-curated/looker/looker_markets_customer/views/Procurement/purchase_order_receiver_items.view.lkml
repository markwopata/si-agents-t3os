
view: purchase_order_receiver_items {
  sql_table_name: procurement.public__silver.purchase_order_receiver_items ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_receiver_item_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ITEM_ID" ;;
  }

  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."ACCEPTED_QUANTITY" ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: modified_by_id {
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format_name: usd_0
  }

  dimension: purchase_order_line_item_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }

  dimension: purchase_order_receiver_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ID" ;;
  }

  dimension: rejected_quantity {
    type: number
    sql: ${TABLE}."REJECTED_QUANTITY" ;;
  }

  dimension_group: _purchase_order_receiver_items_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_RECEIVER_ITEMS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _purchase_order_receiver_items_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_RECEIVER_ITEMS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        purchase_order_receiver_item_id,
  accepted_quantity,
  created_by_id,
  date_archived_time,
  date_created_time,
  date_updated_time,
  modified_by_id,
  price_per_unit,
  purchase_order_line_item_id,
  purchase_order_receiver_id,
  rejected_quantity,
  _purchase_order_receiver_items_effective_start_utc_datetime_time,
  _purchase_order_receiver_items_effective_delete_utc_datetime_time
    ]
  }
}
