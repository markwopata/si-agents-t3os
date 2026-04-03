view: orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ORDERS"
    ;;
  drill_fields: [order_id]

  dimension: order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: accepted_by {
    type: string
    sql: ${TABLE}."ACCEPTED_BY" ;;
  }

  dimension_group: accepted {
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
    sql: CAST(${TABLE}."ACCEPTED_DATE" AS TIMESTAMP_NTZ) ;;
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: delivery_instructions {
    type: string
    sql: ${TABLE}."DELIVERY_INSTRUCTIONS" ;;
  }

  dimension: delivery_required {
    type: yesno
    sql: ${TABLE}."DELIVERY_REQUIRED" ;;
  }

  dimension: external_id {
    type: string
    sql: ${TABLE}."EXTERNAL_ID" ;;
  }

  dimension: insurance_covers_rental {
    type: yesno
    sql: ${TABLE}."INSURANCE_COVERS_RENTAL" ;;
  }

  dimension: insurance_policy_id {
    type: number
    sql: ${TABLE}."INSURANCE_POLICY_ID" ;;
  }

  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: market_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
  }

  dimension: purchase_order_id {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: supplier_company_id {
    type: number
    sql: ${TABLE}."SUPPLIER_COMPANY_ID" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: last_1_day_orders {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -1, current_date()), ${order_id}, null) ;;
    drill_fields: [order_detail*]
  }

  measure: last_7_days_orders {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -7, current_date()), ${order_id}, null) ;;
    drill_fields: [order_detail*]
  }

  measure: last_30_days_orders {
    type: count_distinct
    sql: IFF(${date_created_date} >= dateadd('day', -30, current_date()), ${order_id}, null) ;;
    drill_fields: [order_detail*]
  }

  measure: count_orders {
    type: count_distinct
    sql: ${order_id} ;;
    drill_fields: [order_detail*]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: order_detail {
    fields: [
      order_id,
      date_created_date,
      rental_coordinator_metrics.employee_name
    ]
  }

  set: detail {
    fields: [
      order_id,
      users.employer_user_id,
      users.username,
      users.middle_name,
      users.last_name,
      users.first_name,
      users.company_name,
      markets.name,
      markets.market_id,
      markets.canonical_name,
      deliveries.count,
      rentals.count
    ]
  }
}
