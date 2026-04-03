view: company_purchase_orders {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_PURCHASE_ORDERS"
    ;;
  drill_fields: [company_purchase_order_id]

  dimension: company_purchase_order_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_ID" ;;
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

  dimension_group: approved {
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
    sql: CAST(${TABLE}."APPROVED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: approved_by_user_id {
    type: number
    sql: ${TABLE}."APPROVED_BY_USER_ID" ;;
  }

  dimension: company_purchase_order_type_id {
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_TYPE_ID" ;;
  }

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: modified {
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
    sql: CAST(${TABLE}."MODIFIED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: pdf {
    type: string
    sql: ${TABLE}."PDF" ;;
  }

  dimension_group: submitted {
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
    sql: CAST(${TABLE}."SUBMITTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: submitted_by_user_id {
    type: number
    sql: ${TABLE}."SUBMITTED_BY_USER_ID" ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: status {
    type: string
    label: "Purchase Order Status"
    sql: IFF(${TABLE}."MODIFIED_AT" IS NOT NULL, 'Approved (Modified)', IFF(${TABLE}."APPROVED_AT" IS NOT NULL, 'Approved', IFF(${TABLE}."SUBMITTED_AT" IS NOT NULL, 'Submitted', 'Draft'))) ;;
  }

  measure: count {
    type: count
    drill_fields: [company_purchase_order_id, company_purchase_order_line_items.count]
  }
}
