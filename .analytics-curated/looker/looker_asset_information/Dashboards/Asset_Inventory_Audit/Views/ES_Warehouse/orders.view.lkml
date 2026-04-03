view: orders {
  sql_table_name: "PUBLIC"."ORDERS"
    ;;
  drill_fields: [purchase_order_id]

  dimension: purchase_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
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
    sql: ${TABLE}.CAST(${TABLE}."ACCEPTED_DATE" AS TIMESTAMP_NTZ) ;;
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
    sql: ${TABLE}.CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
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

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: location_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: order_invoice_memo {
    type: string
    sql: ${TABLE}."ORDER_INVOICE_MEMO" ;;
  }

  dimension: order_status_id {
    type: number
    sql: ${TABLE}."ORDER_STATUS_ID" ;;
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
    sql: ${TABLE}."USER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      purchase_order_id,
      locations.nickname,
      locations.location_id,
      orders.purchase_order_id,
      invoices.count,
      orders.count,
      rentals.count
    ]
  }
}
