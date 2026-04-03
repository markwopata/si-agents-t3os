view: non_inventory_items {
  sql_table_name: "PROCUREMENT"."PUBLIC"."NON_INVENTORY_ITEMS" ;;
  drill_fields: [non_inventory_item_id]

  dimension: non_inventory_item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."NON_INVENTORY_ITEM_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
  measure: count {
    type: count
    drill_fields: [non_inventory_item_id, name]
  }
}
