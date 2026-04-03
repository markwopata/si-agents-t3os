view: store_parts {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."STORE_PARTS" ;;
  drill_fields: [store_part_id]

  dimension: store_part_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: available_quantity {
    type: number
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }
  dimension: custom_name {
    type: string
    sql: ${TABLE}."CUSTOM_NAME" ;;
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
  dimension: inventory_location_id {
    type: number
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }
  dimension: item_type_id {
    type: number
    sql: ${TABLE}."ITEM_TYPE_ID" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: max {
    type: number
    sql: ${TABLE}."MAX" ;;
  }
  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }
  dimension: part_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: rental_location_id {
    type: number
    sql: ${TABLE}."RENTAL_LOCATION_ID" ;;
  }
  dimension: search_vector {
    type: string
    sql: ${TABLE}."SEARCH_VECTOR" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: store_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: threshold {
    type: number
    sql: ${TABLE}."THRESHOLD" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }
  measure: total_qty {
    type: sum
    sql: ${TABLE}."QUANTITY" ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  store_part_id,
  custom_name,
  parts.part_id,
  parts.name,
  stores.name,
  stores.store_id
  ]
  }

}
