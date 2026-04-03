view: purchase_orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."PURCHASE_ORDERS" ;;
  drill_fields: [purchase_order_id]

  dimension: active {
    type: string
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: budget_amount {
    type: number
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: currency_type {
    type:  string
    sql: ${TABLE}."CUURENCY_TYPE" ;;
  }

  dimension_group: date_created {
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
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: end_date {
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
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension_group: _ES_UPDATE_TIMESTAMP {
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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: name {
    type:  string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: purchase_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension_group: start_date {
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: universal_entity_id {
    type: number
    sql: ${TABLE}."universal_entity_id" ;;
  }
}
