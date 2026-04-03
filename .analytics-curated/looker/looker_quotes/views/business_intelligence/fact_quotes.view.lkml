view: fact_quotes {
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
    hidden: yes
  }

  dimension: converted_to_order_by_user_key {
    type: string
    sql: ${TABLE}."CONVERTED_TO_ORDER_BY_USER_KEY" ;;
    hidden: yes
  }

  dimension: created_date_key {
    type: string
    sql: ${TABLE}."CREATED_DATE_KEY" ;;
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

  dimension: quote_created_by_user_key {
    type: string
    sql: ${TABLE}."QUOTE_CREATED_BY_USER_KEY" ;;
    hidden: yes
  }

  dimension: quote_contact_user_key {
    type: string
    sql: ${TABLE}."QUOTE_CONTACT_USER_KEY" ;;
    hidden: yes
  }

  dimension: quote_customer_key {
    type: string
    sql: ${TABLE}."QUOTE_CUSTOMER_KEY" ;;
    hidden: yes
  }

  dimension: quote_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."QUOTE_KEY" ;;
    hidden: yes
  }

  dimension: order_key {
    type: string
    sql: ${TABLE}."ORDER_KEY" ;;
    hidden: yes
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

  dimension: updated_date_key {
    type: string
    sql: ${TABLE}."UPDATED_DATE_KEY" ;;
  }

  dimension: num_days_quoted {
    type: number
    sql: ${TABLE}."NUM_DAYS_QUOTED" ;;
  }

  dimension: rental_subtotal {
    type: number
    sql: ${TABLE}."RENTAL_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: pickup_fee {
    type: number
    sql: ${TABLE}."PICKUP_FEE" ;;
    value_format_name: usd
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

  dimension: total_price {
    type: number
    sql: ${TABLE}."TOTAL_PRICE" ;;
    value_format_name: usd
  }

  dimension: total_rpp_price {
    type: number
    sql: ${TABLE}."TOTAL_RPP_PRICE" ;;
    value_format_name: usd
  }

  measure: current_quotes {
    type: count_distinct
    sql: ${quote_key} ;;
  }

  filter: user_date_range {
    type: date
    description: "User-selected date range for current vs previous comparison"
  }

  dimension: timeframe {
    type: string
    sql:
    CASE
      WHEN ${quote_created_date.date_raw} >= {% date_start user_date_range %}
       AND ${quote_created_date.date_raw} <= {% date_end user_date_range %}
        THEN 'Current'

      WHEN ${quote_created_date.date_raw} >=
      dateadd(
      day,
      -datediff(
      day,
      {% date_start user_date_range %},
      {% date_end user_date_range %}
      ),
      {% date_start user_date_range %}
      )
      AND ${quote_created_date.date_raw} < {% date_start user_date_range %}
      THEN 'Previous'
      END
      ;;
  }


  measure: total_count_of_previous_quotes {
    type: count_distinct
    sql: ${quote_key} ;;
    filters: [timeframe: "Previous", quote_key: "-NULL"]
    drill_fields: [quote_info*]
  }

  measure: total_count_of_current_quotes {
    type: count_distinct
    sql: ${quote_key} ;;
    filters: [timeframe: "Current", quote_key: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_quotes._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_quotes._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_quotes._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    drill_fields: [quote_info*]
  }

  measure: total_count_of_current_orders {
    type: count_distinct
    sql: ${order_key} ;;
    filters: [timeframe: "Current", quote_key: "-NULL"]
    html:
    <a href="#drillmenu" style = "color:#000000;" target="_self">
    {{ rendered_value }} {% if difference_in_orders._value > 0 %}

      {% assign indicator = "green,▲" | split: ',' %}

      {% elsif difference_in_quotes._value < 0 %}

      {% assign indicator = "red,▼" | split: ',' %}

      {% else %}

      {% endif %}

      <font color="{{indicator[0]}}">

      {% if value == 99999.12345 %} &infin

      {% else %}({{ difference_in_orders._rendered_value }})

      {% endif %} {{indicator[1]}}

      </font>
      </a>;;
    drill_fields: [order_info*]
    }

  measure: difference_in_quotes {
    type: number
    sql: ${total_count_of_current_quotes} - ${total_count_of_previous_quotes} ;;
  }


  measure: difference_in_orders {
    type: number
    sql: ${total_count_of_current_orders} - ${total_count_of_previous_orders} ;;
  }

  measure: total_count_of_previous_orders {
    type: count_distinct
    sql: ${order_key};;
    filters: [timeframe: "Previous", order_key: "-NULL"]
    drill_fields: [order_info*]
  }

  measure: total_missed_revenue_availability {
    group_label: "Total Potential Revenue From Missed Rentals"
    type: sum
    sql: ${rental_subtotal} ;;
    filters: [dim_quotes.missed_quote_reason: "Availability", timeframe: "Current"]
    value_format_name: usd_0
  }

  measure: total_count_of_current_availability_missed_quote_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_key};;
    filters: [timeframe: "Current", quote_key: "-NULL", dim_quotes.missed_quote_reason: "Availability"]
    drill_fields: [dim_quotes.missed_quote_reason_details*]
    html: {{rendered_value}}
          <td>
          <span style="color: #8C8C8C; font-size: 12px;"> {{total_missed_revenue_availability._rendered_value}} Missed Revenue </span>
          </td>;;
  }

  measure: total_missed_revenue_transport {
    group_label: "Total Potential Revenue From Missed Rentals"
    type: sum
    sql: ${rental_subtotal} ;;
    filters: [dim_quotes.missed_quote_reason: "Lack of Transport", timeframe: "Current"]
    value_format_name: usd_0
  }

  measure: total_missed_revenue_rate {
    group_label: "Total Potential Revenue From Missed Rentals"
    type: sum
    sql: ${rental_subtotal} ;;
    filters: [dim_quotes.missed_quote_reason: "Rate", timeframe: "Current"]
    value_format_name: usd_0
  }

  measure: total_missed_revenue_other {
    group_label: "Total Potential Revenue From Missed Rentals"
    type: sum
    sql: ${rental_subtotal} ;;
    filters: [dim_quotes.missed_quote_reason: "Other", timeframe: "Current"]
    value_format_name: usd_0
  }

  measure: total_count_of_current_transport_missed_quote_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_key};;
    filters: [timeframe: "Current", quote_key: "-NULL", dim_quotes.missed_quote_reason: "Lack of Transport"]
    drill_fields: [dim_quotes.missed_quote_reason_details*]
    html: {{rendered_value}}
          <td>
          <span style="color: #8C8C8C; font-size: 12px;"> {{total_missed_revenue_transport._rendered_value}} Missed Revenue </span>
          </td>;;
  }

  measure: total_count_of_current_rate_missed_quote_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_key};;
    filters: [timeframe: "Current", quote_key: "-NULL", dim_quotes.missed_quote_reason: "Rate"]
    drill_fields: [dim_quotes.missed_quote_reason_details*]
    html: {{rendered_value}}
          <td>
          <span style="color: #8C8C8C; font-size: 12px;"> {{total_missed_revenue_rate._rendered_value}} Missed Revenue </span>
          </td>;;
  }

  measure: total_count_of_current_other_missed_quote_reason {
    group_label: "Missed Rental Reasons"
    type: count_distinct
    sql: ${quote_key};;
    filters: [timeframe: "Current", quote_key: "-NULL", dim_quotes.missed_quote_reason: "Other"]
    drill_fields: [dim_quotes.missed_quote_reason_details*]
    html: {{rendered_value}}
          <td>
          <span style="color: #8C8C8C; font-size: 12px;"> {{total_missed_revenue_other._rendered_value}} Missed Revenue </span>
          </td>;;
  }


  measure: total_count_of_current_quotes_unformatted{
    type: period_over_period
    description: "Order count from the previous year"
    based_on: current_quotes
    based_on_time: _created_recordtimestamp_date
    period: month
    kind: previous
  }

# In the fact_quotes view file
  dimension: is_guaranteed {
    type: yesno
    sql: EXISTS(
          SELECT 1
          FROM "BUSINESS_INTELLIGENCE"."GOLD"."V_BRIDGE_QUOTE_SALESPERSON" b
          INNER JOIN "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_USERS_BI" u
            ON b."SALESPERSON_USER_KEY" = u."USER_KEY"
          INNER JOIN "ANALYTICS"."BI_OPS"."GUARANTEES_COMMISSIONS_STATUS" g
            ON u."USER_ID" = g."SALESPERSON_USER_ID"
          WHERE b."QUOTE_KEY" = ${TABLE}."QUOTE_KEY"
          AND g."CURRENT_GUARANTEE_STATUS" = 'On Guarantee'
        ) ;;
  }

  measure: conversion_rate {
    type: number
    sql: ${total_count_of_current_orders}::FLOAT / NULLIF(${total_count_of_current_quotes}, 0)::FLOAT ;;
    value_format_name: percent_2
    description: "Quote to order conversion rate"
  }

  set: quote_info {
    fields: [
      v_markets.location,
      dim_quotes.quote_number,
      quote_created_date.formatted_date,
      quote_customers.customer_name,
      dim_companies.company_id,
      salesperson.user_full_name,
      dim_equipment_classes.equipment_class_name,
      int_rental_floor_rate_analysis.floor_day_rate,
      int_rental_floor_rate_analysis.floor_week_rate,
      int_rental_floor_rate_analysis.floor_month_rate,
      dim_equipment_classes.category_name,
      dim_quotes.quote_status
      ]
  }

  set: order_info {
    fields: [
      v_markets.location,
      dim_quotes.quote_id,
      orders_from_quotes.order_id,
      quote_created_date.formatted_date,
      quote_customers.customer_name,
      dim_companies.company_id,
      salesperson.user_full_name,
      dim_equipment_classes.equipment_class_name,
      dim_equipment_classes.category_name
      ]
  }


























  measure: count {
    type: count
  }
}
