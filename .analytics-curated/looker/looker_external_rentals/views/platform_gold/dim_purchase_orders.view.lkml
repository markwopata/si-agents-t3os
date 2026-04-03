view: dim_purchase_orders {
  sql_table_name: "PLATFORM"."GOLD"."V_PURCHASE_ORDERS" ;;

  # PRIMARY KEY
  dimension: purchase_order_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_KEY" ;;
    hidden: yes
  }

  # NATURAL KEYS
  dimension: purchase_order_source {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_SOURCE" ;;
    description: "Source system for purchase order data"
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    description: "Natural purchase order ID"
    value_format_name: id
  }

  # PURCHASE ORDER DETAILS
  dimension: purchase_order_name {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NAME" ;;
    description: "Purchase order name"
    full_suggestions: yes
  }

  dimension: purchase_order_active {
    type: yesno
    sql: ${TABLE}."PURCHASE_ORDER_ACTIVE" ;;
    description: "Purchase order is active"
  }

  dimension: purchase_order_budget_amount {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_BUDGET_AMOUNT" ;;
    description: "Purchase order budget amount"
    value_format_name: usd
  }

  dimension: purchase_order_company_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_COMPANY_ID" ;;
    description: "Company ID for purchase order"
  }

  dimension: purchase_order_created_by {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_CREATED_BY" ;;
    description: "User ID who created the purchase order"
  }

  dimension: purchase_order_currency_type {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_CURRENCY_TYPE" ;;
    description: "Currency type for purchase order"
  }

  # PURCHASE ORDER DATES
  dimension_group: purchase_order_date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASE_ORDER_DATE_CREATED" AS TIMESTAMP_NTZ) ;;
    description: "Date purchase order was created"
  }

  dimension_group: purchase_order_start_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASE_ORDER_START_DATE" AS TIMESTAMP_NTZ) ;;
    description: "Purchase order start date"
  }

  dimension_group: purchase_order_end_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASE_ORDER_END_DATE" AS TIMESTAMP_NTZ) ;;
    description: "Purchase order end date"
  }

  # MEASURES
  measure: count {
    type: count
    description: "Number of purchase orders"
    drill_fields: [purchase_order_id, purchase_order_name]
  }

  measure: total_budget_amount {
    type: sum
    sql: ${TABLE}."PURCHASE_ORDER_BUDGET_AMOUNT" ;;
    description: "Total budget amount across all purchase orders"
    value_format_name: usd
  }

  # TIMESTAMP
  dimension_group: purchase_order_recordtimestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PURCHASE_ORDER_RECORDTIMESTAMP" AS TIMESTAMP_NTZ) ;;
    description: "When this purchase order record was created"
  }
}
