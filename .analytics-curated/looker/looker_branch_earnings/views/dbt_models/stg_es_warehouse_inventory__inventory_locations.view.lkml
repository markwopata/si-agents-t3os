view: stg_es_warehouse_inventory__inventory_locations {
  sql_table_name: "INTACCT_MODELS"."STG_ES_WAREHOUSE_INVENTORY__INVENTORY_LOCATIONS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
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
  dimension: inventory_type_id {
    type: number
    sql: ${TABLE}."INVENTORY_TYPE_ID" ;;
  }
  dimension: is_default_store {
    type: yesno
    sql: ${TABLE}."IS_DEFAULT_STORE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [store_name]
  }
}
