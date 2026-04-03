view: dim_shopify_order_header {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_SHOPIFY_ORDER_HEADER" ;;

  dimension: cancel_reason {
    type: string
    sql: ${TABLE}."CANCEL_REASON" ;;
  }

  dimension_group: cancelled_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CANCELLED_TIMESTAMP" ;;
  }

  dimension_group: order_created { ## how to re-work this for refund date
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."CREATED_TIMESTAMP" ;;
  }

  dimension: cost_matching_date {
    type: date
    sql: iff(${TABLE}."CREATED_TIMESTAMP"::date < '2024-11-01', '2024-11-01', date_trunc(month, ${TABLE}."CREATED_TIMESTAMP"::date)) ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: external_customer_order {
    type: yesno
    sql: coalesce(${dim_customers.customer_name},'none') not ilike 'EquipmentShare%' and coalesce(${email},'none') not ilike '%equipmentshare%';;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: match_id {
    primary_key: yes
    type: number
    sql:  ${TABLE}."MATCH_ID" ;;
  }

  dimension: new_vs_repeat {
    type: string
    sql: ${TABLE}."NEW_VS_REPEAT" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: order_number {
    type: number
    value_format_name: id
    sql: ${TABLE}."ORDER_NUMBER" ;;
  }

  dimension: source_name {
    type: string
    sql: ${TABLE}."SOURCE_NAME" ;;
  }

  dimension: sales_channel {
    type: string
    sql: ${TABLE}."SALES_CHANNEL" ;;
  }

  measure: total_orders {
    type: count_distinct
    sql: ${order_id} ;;
  }

}
