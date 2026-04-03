view: price_list_entries {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PRICE_LIST_ENTRIES" ;;
  drill_fields: [price_list_entry_id]

  dimension: price_list_entry_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PRICE_LIST_ENTRY_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension: currency_code_id {
    type: string
    sql: ${TABLE}."CURRENCY_CODE_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension: price_list_id {
    type: string
    sql: ${TABLE}."PRICE_LIST_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [price_list_entry_id]
  }
}
