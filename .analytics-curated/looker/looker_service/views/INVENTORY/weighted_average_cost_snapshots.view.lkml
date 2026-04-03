view: weighted_average_cost_snapshots {
  sql_table_name: "ES_WAREHOUSE"."INVENTORY"."WEIGHTED_AVERAGE_COST_SNAPSHOTS" ;;

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
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension_group: date_applied {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_APPLIED" ;;
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
  dimension: incoming_cost_per_item {
    type: number
    sql: ${TABLE}."INCOMING_COST_PER_ITEM" ;;
  }
  dimension: incoming_quantity {
    type: number
    sql: ${TABLE}."INCOMING_QUANTITY" ;;
  }
  dimension: inventory_location_id {
    type: number
    sql: ${TABLE}."INVENTORY_LOCATION_ID" ;;
  }
  dimension: is_current {
    type: yesno
    sql: ${TABLE}."IS_CURRENT" ;;
  }
  dimension: is_override {
    type: yesno
    sql: ${TABLE}."IS_OVERRIDE" ;;
  }
  dimension: is_system_generated {
    type: yesno
    sql: ${TABLE}."IS_SYSTEM_GENERATED" ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }
  dimension: total_quantity {
    type: number
    sql: ${TABLE}."TOTAL_QUANTITY" ;;
  }
  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }
  dimension: wac_snapshot_id {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_ID" ;;
  }
  dimension: weighted_average_cost {
    type: number
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
  }
  measure: count {
    type: count
  }
}
