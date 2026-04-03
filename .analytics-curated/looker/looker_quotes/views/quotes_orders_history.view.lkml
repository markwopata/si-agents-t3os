
view: quotes_orders_history {
  derived_table: {
    sql: with quotes_last_30_days as (
    {% if location_order_quote_count2.location_breakdown._parameter_value == "'Region'" %}
          select
              m.REGION_NAME AS location,
              count(q.quote_number) as count_of_quotes_last_30,
              count(q.order_id) as count_of_orders_last_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-30,current_date()) and current_date
            group by
              m.REGION_NAME
    {% elsif location_order_quote_count2.location_breakdown._parameter_value == "'District'" %}
          select
              m.DISTRICT AS location,
              count(q.quote_number) as count_of_quotes_last_30,
              count(q.order_id) as count_of_orders_last_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-30,current_date()) and current_date
            group by
              m.DISTRICT
    {% else %}
          select
              m.MARKET_NAME AS location,
              count(q.quote_number) as count_of_quotes_last_30,
              count(q.order_id) as count_of_orders_last_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-30,current_date()) and current_date
            group by
              m.MARKET_NAME
    {% endif %}
      ),
      quotes_prior_30_days as (
    {% if location_order_quote_count2.location_breakdown._parameter_value == "'Region'" %}
          select
              m.REGION_NAME AS location,
              count(q.quote_number) as count_of_quotes_prior_30,
              count(q.order_id) as count_of_orders_prior_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-61,current_date()) and dateadd(day,-31,current_date())
            group by
              m.REGION_NAME
    {% elsif location_order_quote_count2.location_breakdown._parameter_value == "'District'" %}
          select
              m.DISTRICT AS location,
              count(q.quote_number) as count_of_quotes_prior_30,
              count(q.order_id) as count_of_orders_prior_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-61,current_date()) and dateadd(day,-31,current_date())
            group by
              m.DISTRICT
    {% else %}
          select
              m.MARKET_NAME AS location,
              count(q.quote_number) as count_of_quotes_prior_30,
              count(q.order_id) as count_of_orders_prior_30
            from quotes.quotes.quote as q
              left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK as m
                on q.branch_id = m.MARKET_ID
            where q.created_date between dateadd(day,-61,current_date()) and dateadd(day,-31,current_date())
            group by
              m.MARKET_NAME
    {% endif %}
      )
      select quotes_last_30_days.location,
             count_of_quotes_last_30,
             count_of_orders_last_30,
             count_of_quotes_prior_30,
             count_of_orders_prior_30,
             (count_of_quotes_last_30-count_of_quotes_prior_30)/count_of_quotes_prior_30
                 as percent_change_of_quotes,
             (count_of_orders_last_30-count_of_orders_prior_30)/case when count_of_orders_prior_30 = 0 then null else count_of_orders_prior_30 end
                 as percent_change_of_orders
      from quotes_last_30_days
          left join quotes_prior_30_days
              on quotes_prior_30_days.location = quotes_last_30_days.location ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: count_of_quotes_last_30 {
    type: number
    sql: ${TABLE}."COUNT_OF_QUOTES_LAST_30" ;;
  }

  dimension: count_of_orders_last_30 {
    type: number
    sql: ${TABLE}."COUNT_OF_ORDERS_LAST_30" ;;
  }

  dimension: count_of_quotes_prior_30 {
    type: number
    sql: ${TABLE}."COUNT_OF_QUOTES_PRIOR_30" ;;
  }

  dimension: count_of_orders_prior_30 {
    type: number
    sql: ${TABLE}."COUNT_OF_ORDERS_PRIOR_30" ;;
  }

  dimension: percent_change_of_quotes {
    type: number
    sql: ${TABLE}."PERCENT_CHANGE_OF_QUOTES" ;;
  }

  dimension: percent_change_of_orders {
    type: number
    sql: ${TABLE}."PERCENT_CHANGE_OF_ORDERS" ;;
  }

  measure: count_of_quotes_last_30_days {
    type: sum
    sql: ${TABLE}."COUNT_OF_QUOTES_LAST_30" ;;
  }

  measure: count_of_orders_last_30_days {
    type: sum
    sql: ${TABLE}."COUNT_OF_ORDERS_LAST_30" ;;
  }

  measure: count_of_quotes_prior_30_days {
    type: sum
    sql: ${TABLE}."COUNT_OF_QUOTES_PRIOR_30" ;;
  }

  measure: count_of_orders_prior_30_days {
    type: sum
    sql: ${TABLE}."COUNT_OF_ORDERS_PRIOR_30" ;;
  }

  measure: percentage_change_of_quotes {
    type: sum
    sql: ${TABLE}."PERCENT_CHANGE_OF_QUOTES";;
    html:

    {% if value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

  {% endif %}

  <font color="{{indicator[0]}}">

  {% if value == 99999.12345 %} &infin

  {% else %}{{rendered_value}}

  {% endif %} {{indicator[1]}}

  </font> ;;
    value_format_name: "percent_1"
  }

  measure: percentage_change_of_orders {
    type: sum
    sql: ${TABLE}."PERCENT_CHANGE_OF_ORDERS";;
    html:

    {% if value > 0 %}

    {% assign indicator = "green,▲" | split: ',' %}

    {% elsif value < 0 %}

    {% assign indicator = "red,▼" | split: ',' %}

    {% else %}

    {% endif %}

    <font color="{{indicator[0]}}">

    {% if value == 99999.12345 %} &infin

    {% else %}{{rendered_value}}

    {% endif %} {{indicator[1]}}

    </font> ;;
    value_format_name: "percent_1"
  }

  measure: conversion_rate_last_30_days {
    type: number
    sql: ${count_of_orders_last_30_days}/${count_of_quotes_last_30_days} ;;
    value_format_name: "percent_1"
  }

  set: detail {
    fields: [
        location,
  count_of_quotes_last_30,
  count_of_orders_last_30,
  count_of_quotes_prior_30,
  count_of_orders_prior_30,
  percent_change_of_quotes,
  percent_change_of_orders
    ]
  }
}
