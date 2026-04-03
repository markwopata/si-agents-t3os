view: open_invoice_details {
  sql_table_name: "ANALYTICS"."BI_OPS"."MARKET_ACTION_ITEMS" ;;

  dimension: item {
    type: string
    sql: ${TABLE}."ITEM" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  measure: item_count {
    type: sum
    sql: ${TABLE}."ITEM_COUNT" ;;
  }

  dimension: _update_timestamp {
    type: date_time
    sql: ${TABLE}."_UPDATE_TIMESTAMP" ;;
  }

}
