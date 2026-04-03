
view: quote_order_counts {
sql_table_name: analytics.bi_ops.salesperson_quote_order_counts;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: date {
    type: time
    sql: ${TABLE}."DATE" ;;
    timeframes: [date, month, year]
    html: {{ rendered_value | date: "%b %d" }};;

  }

  dimension: salesperson_full_name {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SALESPERSON_FULL_NAME" ;;
  }

  dimension: salesperson_user_id {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: salesperson_current_location {
    group_label: "Sales Person Info"
    type: string
    sql: ${TABLE}."SALESPERSON_CURRENT_LOCATION" ;;
  }

dimension: salesperson_current_title {
  group_label: "Sales Person Info"
  type: string
  sql: ${TABLE}."SALESPERSON_CURRENT_TITLE" ;;
}

  dimension: rep {
    type: string
    sql: concat(${salesperson_full_name},' - ', ${salesperson_current_location}) ;;
  }

  dimension: total_quotes {
    type: number
    sql: ${TABLE}."TOTAL_QUOTES" ;;
  }
  measure: total_quote_sum {
    type: sum
    sql: ${total_quotes} ;;
  }

  dimension: total_orders {
    type: number
    sql: ${TABLE}."TOTAL_ORDERS" ;;
  }

  measure: total_order_sum {
    type: sum
    sql: ${total_orders} ;;
  }

  measure: daily_conversion_rate {
    type: number
    sql: CASE WHEN ${total_order_sum} = 0 THEN 0 ELSE COALESCE(DIV0NULL(${total_order_sum}, ${total_quote_sum}),0) END ;;
    value_format_name: percent_1
  }

  measure: avg_daily_conversion_rate {
    hidden: yes
    type: number
    sql: (SUM(${total_orders}) / SUM(${total_quotes})) / (COUNT(distinct ${date_date}) * COUNT(distinct ${salesperson_user_id}));;
    value_format_name: percent_1
  }



  dimension: rolling_7_day_quotes {
    type: number
    sql: ${TABLE}."ROLLING_7_DAY_QUOTES" ;;
  }
  measure: rolling_7_day_quotes_sum {
    type: sum
    label: "Total Quotes - Last 7 Days"
    sql: ${rolling_7_day_quotes} ;;
  }

  dimension: rolling_7_day_orders {
    type: number
    sql: ${TABLE}."ROLLING_7_DAY_ORDERS" ;;
  }
  measure: rolling_7_day_orders_sum {
    type: sum
    sql: ${rolling_7_day_orders} ;;
    label: "Total Orders - Last 7 Days"
  }

  measure: rolling_7_conversion_rate {
    type: number
    sql: CASE WHEN ${rolling_7_day_orders_sum} = 0 THEN 0 ELSE COALESCE(DIV0NULL(${rolling_7_day_orders_sum}, ${rolling_7_day_quotes_sum}),0) END;;
    value_format_name: percent_1
    drill_fields: [rolling_7_drill*]
  }


  dimension: rolling_30_day_quotes {
    type: number
    sql: ${TABLE}."ROLLING_30_DAY_QUOTES" ;;
  }
  measure: rolling_30_day_quotes_sum {
    type: sum
    label: "Total Quotes - Last 30 Days"
    sql: ${rolling_30_day_quotes} ;;
  }

  dimension: rolling_30_day_orders {
    type: number
    sql: ${TABLE}."ROLLING_30_DAY_ORDERS" ;;
  }
  measure: rolling_30_day_orders_sum {
    type: sum
    sql: ${rolling_30_day_orders} ;;
    label: "Total Orders - Last 30 Days"
  }

  measure: rolling_30_conversion_rate {
    type: number
    sql: CASE WHEN ${rolling_30_day_orders_sum} = 0 THEN 0 ELSE COALESCE(DIV0NULL(${rolling_30_day_orders_sum}, ${rolling_30_day_quotes_sum}),0) END;;
    value_format_name: percent_1
    drill_fields: [rolling_30_drill*]
  }

  set: rolling_7_drill {
    fields: [
      date_date,
      rolling_7_day_quotes_sum,
      rolling_7_day_orders_sum
    ]
  }

  set: rolling_30_drill {
    fields: [
      date_date,
      rolling_30_day_quotes_sum,
      rolling_30_day_orders_sum
    ]
  }

  set: detail {
    fields: [
        date_date,
  salesperson_full_name,
  salesperson_user_id,
  salesperson_current_location,
  total_quotes,
  total_orders
    ]
  }
}
