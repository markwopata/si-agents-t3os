view: month_end_t3_inventory_valuation {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."T3_PARTS_INVENTORY_VALUATION_REPORT_SNAPSHOT" ;;

  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension_group: month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MONTH" ;;
  }
  dimension: most_recent_purchase_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."MOST_RECENT_PURCHASE_COST" ;;
  }
  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }
  dimension: store_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: store_name {
    type: string
    sql: ${TABLE}."STORE_NAME" ;;
  }
  dimension: store_part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."STORE_PART_ID" ;;
  }
  dimension: total_qty {
    type: number
    sql: ${TABLE}."TOTAL_QTY" ;;
  }
  dimension: wac_snapshot_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WAC_SNAPSHOT_ID" ;;
  }
  dimension: weighted_average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, provider_name, store_name]
  }
}
