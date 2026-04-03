view: parts_cogs_monthly_report {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."PARTS_COGS_MONTHLY_REPORT" ;;

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AVERAGE_COST" ;;
  }
  dimension: branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension: cost_plus_freight {
    type: number
    value_format_name: usd
    sql: ${TABLE}."COST_PLUS_FREIGHT" ;;
  }
  measure: cogs_plus_freight {
    type: sum
    value_format_name: usd
    sql: ${cost_plus_freight} ;;
  }
  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: intacct_location_id {
    type: string
    sql: ${TABLE}."INTACCT_LOCATION_ID" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."INVOICE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: line_item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_COST" ;;
  }
  measure: cogs {
    type: sum
    value_format_name: usd
    sql: ${total_cost} ;;
  }
  measure: count {
    type: count
    drill_fields: [customer_name]
  }
}
