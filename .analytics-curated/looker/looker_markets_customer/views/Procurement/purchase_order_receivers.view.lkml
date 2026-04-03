
view: purchase_order_receivers {
  sql_table_name:procurement.public__silver.purchase_order_receivers ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_receiver_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_RECEIVER_ID" ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_received {
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: modified_by_id {
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: receiver_type {
    type: string
    sql: ${TABLE}."RECEIVER_TYPE" ;;
  }

  dimension: store_id {
    type: string
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: transaction_id {
    type: string
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension_group: _purchase_order_receivers_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_RECEIVERS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _purchase_order_receivers_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDER_RECEIVERS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        purchase_order_receiver_id,
  created_by_id,
  date_created_time,
  date_received_time,
  date_updated_time,
  modified_by_id,
  note,
  purchase_order_id,
  receiver_type,
  store_id,
  transaction_id,
  _purchase_order_receivers_effective_start_utc_datetime_time,
  _purchase_order_receivers_effective_delete_utc_datetime_time
    ]
  }
}
