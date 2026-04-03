view: fact_quote_line_items {
  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_FACT_QUOTE_LINE_ITEMS" ;;

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }

  dimension: created_date_key {
    type: string
    sql: ${TABLE}."CREATED_DATE_KEY" ;;
    hidden: yes
  }

  dimension: equipment_class_key {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_KEY" ;;
    hidden: yes
  }

  dimension: expiration_date_key {
    type: string
    sql: ${TABLE}."EXPIRATION_DATE_KEY" ;;
    hidden: yes
  }

  dimension: expiration_time_key {
    type: string
    sql: ${TABLE}."EXPIRATION_TIME_KEY" ;;
    hidden: yes
  }

  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
    hidden: yes
  }

  dimension: order_key {
    type: string
    sql: ${TABLE}."ORDER_KEY" ;;
  }

  dimension: part_key {
    type: string
    sql: ${TABLE}."PART_KEY" ;;
  }

  dimension: quote_customer_key {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
  }

  dimension: quote_contact_user_key {
    type: string
    sql: ${TABLE}."QUOTE_CONTACT_USER_KEY" ;;
    hidden: yes
  }

  dimension: quote_key {
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
  }

  dimension: requested_end_date_key {
    type: string
    sql: ${TABLE}."REQUESTED_END_DATE_KEY" ;;
    hidden: yes
  }

  dimension: requested_end_time_key {
    type: string
    sql: ${TABLE}."REQUESTED_END_TIME_KEY" ;;
    hidden: yes
  }

  dimension: requested_start_date_key {
    type: string
    sql: ${TABLE}."REQUESTED_START_DATE_KEY" ;;
    hidden: yes
  }

  dimension: requested_start_time_key {
    type: string
    sql: ${TABLE}."REQUESTED_START_TIME_KEY" ;;
    hidden: yes
  }

  dimension: quote_line_item_key {
    type: string
    sql: ${TABLE}."QUOTE_LINE_ITEM_KEY" ;;
    hidden: yes
  }

  dimension: flat_rate {
    type: number
    sql: ${TABLE}."FLAT_RATE" ;;
  }

  dimension: four_week_rate {
    type: number
    sql: ${TABLE}."FOUR_WEEK_RATE" ;;
  }

  dimension: line_item_description {
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: line_item_type_name {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE_NAME" ;;
  }

  dimension: multiplier {
    type: number
    sql: ${TABLE}."MULTIPLIER" ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: num_days_quoted {
    type: number
    sql: ${TABLE}."NUM_DAYS_QUOTED" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: quote_line_item_id {
    type: string
    sql: ${TABLE}."QUOTE_LINE_ITEM_ID" ;;
  }

  dimension: selected_rate_type_name {
    type: string
    sql: ${TABLE}."SELECTED_RATE_TYPE_NAME" ;;
  }

  dimension: shift_id {
    type: string
    sql: ${TABLE}."SHIFT_ID" ;;
  }

  dimension: shift_name {
    type: string
    sql: ${TABLE}."SHIFT_NAME" ;;
  }

  dimension: week_rate {
    type: number
    sql: ${TABLE}."WEEK_RATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_type_name, selected_rate_type_name, shift_name]
  }
}
