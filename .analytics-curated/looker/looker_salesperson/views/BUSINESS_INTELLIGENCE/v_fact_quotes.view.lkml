view: v_fact_quotes {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_QUOTES" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }
  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
  dimension: converted_to_order_by_user_key {
    hidden: yes
    type: string
    sql: ${TABLE}."CONVERTED_TO_ORDER_BY_USER_KEY" ;;
  }
  dimension: created_date_key {
    hidden: yes
    type: string
    sql: ${TABLE}."CREATED_DATE_KEY" ;;
  }
  dimension: delivery_fee {
    type: number
    sql: ${TABLE}."DELIVERY_FEE" ;;
    value_format_name: usd
  }
  dimension: equipment_charges {
    type: number
    sql: ${TABLE}."EQUIPMENT_CHARGES" ;;
    value_format_name: usd
  }
  dimension: expiration_date_key {
    hidden: yes
    type: string
    sql: ${TABLE}."EXPIRATION_DATE_KEY" ;;
  }
  dimension: expiration_time_key {
    hidden: yes
    type: string
    sql: ${TABLE}."EXPIRATION_TIME_KEY" ;;
  }
  dimension: market_key {
    hidden: yes
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
  }
  dimension: num_days_quoted {
    type: number
    sql: ${TABLE}."NUM_DAYS_QUOTED" ;;
  }
  dimension: order_key {
    hidden: yes
    type: string
    sql: ${TABLE}."ORDER_KEY" ;;
  }
  dimension: pickup_fee {
    type: number
    sql: ${TABLE}."PICKUP_FEE" ;;
    value_format_name: usd
  }
  dimension: quote_contact_user_key {
    hidden: yes
    type: string
    sql: ${TABLE}."QUOTE_CONTACT_USER_KEY" ;;
  }
  dimension: quote_created_by_user_key {
    hidden: yes
    type: string
    sql: ${TABLE}."QUOTE_CREATED_BY_USER_KEY" ;;
  }
  dimension: quote_customer_key {
    hidden: yes
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
  }

  dimension: quote_key {
    primary_key: yes
    hidden: yes
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
  }

  dimension: rental_subtotal {
    type: number
    sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: requested_end_date_key {
    hidden: yes
    type: string
    sql: ${TABLE}."REQUESTED_END_DATE_KEY" ;;
  }

  dimension: requested_end_time_key {
    hidden: yes
    type: string
    sql: ${TABLE}."REQUESTED_END_TIME_KEY" ;;
  }

  dimension: requested_start_date_key {
    hidden: yes
    type: string
    sql: ${TABLE}."REQUESTED_START_DATE_KEY" ;;
  }

  dimension: requested_start_time_key {
    hidden: yes
    type: string
    sql: ${TABLE}."REQUESTED_START_TIME_KEY" ;;
  }

  dimension: sale_items_subtotal {
    type: number
    sql: ${TABLE}."SALE_ITEMS_SUBTOTAL" ;;
    value_format_name: usd

  }
  dimension: sales_tax {
    type: number
    sql: ${TABLE}."SALES_TAX" ;;
    value_format_name: usd

  }

  measure: total_quotes {
    type: count_distinct
    sql: ${TABLE}.quote_key ;;
  }

  dimension: total_price {
    type: number
    sql: ${TABLE}."TOTAL_PRICE" ;;
    value_format_name: usd
  }


  measure: sum_total_price {
    label: "Total Price"
    type: sum
    sql: ${total_price} ;;
    value_format_name: usd_0
  }

  measure: total_price_sum {
    label: "Total Quoted Dollars"
    type: sum
    sql: ${total_price} ;;
    value_format_name: usd
  }

  dimension: total_rpp_price {
    type: number
    sql: ${TABLE}."TOTAL_RPP_PRICE" ;;
    value_format_name: usd
  }

  dimension: updated_date_key {
    hidden: yes
    type: string
    sql: ${TABLE}."UPDATED_DATE_KEY" ;;
  }
  measure: count {
    type: count
  }
}
