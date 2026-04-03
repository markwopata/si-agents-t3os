view: transaction_items {
  derived_table: {
    sql: select *,(quantity_received*cost_per_item) as total_cost from ES_WAREHOUSE.INVENTORY.transaction_items
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
    primary_key: yes
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: quantity_received {
    type: number
    sql: ${TABLE}."QUANTITY_RECEIVED" ;;
  }

  dimension: item_status_id {
    type: number
    sql: ${TABLE}."ITEM_STATUS_ID" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: total_cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  measure: parts_total_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [
      _es_update_timestamp_time,
      date_created_time,
      date_updated_time,
      transaction_item_id,
      transaction_id,
      part_id,
      quantity_ordered,
      quantity_received,
      item_status_id,
      created_by,
      modified_by,
      cost_per_item,
      total_cost
    ]
  }
}
