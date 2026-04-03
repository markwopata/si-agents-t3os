
view: non_inventory_items {
  sql_table_name: procurement.public__silver.non_inventory_items ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: non_inventory_item_id {
    type: string
    sql: ${TABLE}."NON_INVENTORY_ITEM_ID" ;;
  }

  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }

  dimension: is_allocation_required {
    type: yesno
    sql: ${TABLE}."IS_ALLOCATION_REQUIRED" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: _non_inventory_items_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_NON_INVENTORY_ITEMS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _non_inventory_items_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_NON_INVENTORY_ITEMS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        non_inventory_item_id,
  allocation_type,
  is_allocation_required,
  item_id,
  name,
  _non_inventory_items_effective_start_utc_datetime_time,
  _non_inventory_items_effective_delete_utc_datetime_time
    ]
  }
}
