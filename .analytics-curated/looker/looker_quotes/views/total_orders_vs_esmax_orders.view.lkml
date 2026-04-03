
view: total_orders_vs_esmax_orders {
  derived_table: {
    sql: with total_orders as (
      select concat(u.FIRST_NAME, ' ', u.LAST_NAME, ' - ', u.USER_ID) as total_salesperson,
             os.USER_ID as total_user_id,
             xw.REGION_NAME as total_region_name,
             xw.DISTRICT as total_district,
             o.MARKET_ID as total_market_id,
             xw.MARKET_NAME as total_market_name,
             o.ORDER_ID as total_order_id,
             o.DATE_CREATED as total_date_created
      from ES_WAREHOUSE.PUBLIC.ORDERS o
          join ES_WAREHOUSE.PUBLIC.ORDER_SALESPERSONS os
          on o.ORDER_ID = os.ORDER_ID
          left join ES_WAREHOUSE.PUBLIC.USERS u
          on os.USER_ID = u.USER_ID
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
          on xw.MARKET_ID = o.MARKET_ID
      where o.USER_ID not in (1851) and xw.MARKET_NAME is not null
      ),
      esmax_orders as (
      select concat(u.FIRST_NAME, ' ', u.LAST_NAME, ' - ', u.USER_ID) as es_salesperson,
             q.SALES_REP_ID as es_user_id,
             xw.REGION_NAME as es_region_name,
             xw.DISTRICT as es_district,
             q.BRANCH_ID as es_market_id,
             xw.MARKET_NAME as es_market_name,
             q.ORDER_ID as es_order_id,
             q.ORDER_CREATED_DATE as es_date_created
      from QUOTES.QUOTES.QUOTE q
          left join ES_WAREHOUSE.PUBLIC.USERS u
          on q.SALES_REP_ID = u.USER_ID
          left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
          on q.BRANCH_ID = xw.MARKET_ID
      where ORDER_ID is not null
      )
      select o.*,
             eo.*
      from total_orders o
          full outer join esmax_orders eo
          on o.total_order_id = eo.es_order_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: total_salesperson {
    type: string
    sql: ${TABLE}."TOTAL_SALESPERSON" ;;
  }

  dimension: total_user_id {
    type: string
    sql: ${TABLE}."TOTAL_USER_ID" ;;
  }

  dimension: total_region_name {
    type: string
    sql: ${TABLE}."TOTAL_REGION_NAME" ;;
  }

  dimension: total_district {
    type: string
    sql: ${TABLE}."TOTAL_DISTRICT" ;;
  }

  dimension: total_market_id {
    type: string
    sql: ${TABLE}."TOTAL_MARKET_ID" ;;
  }

  dimension: total_market_name {
    type: string
    sql: ${TABLE}."TOTAL_MARKET_NAME" ;;
  }

  dimension: total_order_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."TOTAL_ORDER_ID" ;;
  }

  dimension_group: total_date_created {
    type: time
    sql: ${TABLE}."TOTAL_DATE_CREATED" ;;
  }

  dimension: es_salesperson {
    type: string
    sql: ${TABLE}."ES_SALESPERSON" ;;
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}."ES_USER_ID" ;;
  }

  dimension: es_region_name {
    type: string
    sql: ${TABLE}."ES_REGION_NAME" ;;
  }

  dimension: es_district {
    type: string
    sql: ${TABLE}."ES_DISTRICT" ;;
  }

  dimension: es_market_id {
    type: string
    sql: ${TABLE}."ES_MARKET_ID" ;;
  }

  dimension: es_market_name {
    type: string
    sql: ${TABLE}."ES_MARKET_NAME" ;;
  }

  dimension: es_order_id {
    type: string
    sql: ${TABLE}."ES_ORDER_ID" ;;
  }

  dimension_group: es_date_created {
    type: time
    sql: ${TABLE}."ES_DATE_CREATED" ;;
  }

  measure: total_count_of_orders {
    type: count_distinct
    sql: ${total_order_id} ;;
    drill_fields: [total_order_info*]
  }

  measure: total_count_of_es_max_orders {
    type: count_distinct
    sql: ${es_order_id} ;;
    filters: [es_salesperson: "-NULL"]
    drill_fields: [es_max_order_info*]
  }

  measure: orders_outside_of_esmax {
    type: count_distinct
    sql: ${total_order_id} ;;
    filters: [es_salesperson: "NULL"]
    drill_fields: [total_order_info*]
  }

  measure: percentage_of_orders_within_esmax {
    type: number
    sql: ${total_count_of_es_max_orders}/${total_count_of_orders} ;;
    value_format_name: percent_1
  }

  set: total_order_info {
    fields: [total_order_id,
      total_market_name,
      total_salesperson,
      total_date_created_date]
  }

  set: es_max_order_info {
    fields: [es_order_id,
      es_market_name,
      es_salesperson,
      es_date_created_date]
  }

  set: detail {
    fields: [
        total_salesperson,
  total_user_id,
  total_market_id,
  total_market_name,
  total_order_id,
  total_date_created_time,
  es_salesperson,
  es_user_id,
  es_market_id,
  es_market_name,
  es_order_id,
  es_date_created_time
    ]
  }
}
