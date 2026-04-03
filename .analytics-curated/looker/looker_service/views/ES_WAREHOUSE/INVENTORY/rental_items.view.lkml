view: rental_items {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."RENTAL_ITEMS" ;;
  drill_fields: [rental_item_id]

  dimension: rental_item_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ITEM_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: quantity_on_rent {
    label: "Inventory Allocated to Rental"
    type: number
    sql: zeroifnull(${TABLE}."QUANTITY_ON_RENT") ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [rental_item_id]
  }
}
