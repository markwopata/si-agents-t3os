view: company_purchase_order_audit_log {
  sql_table_name: "PUBLIC"."COMPANY_PURCHASE_ORDER_AUDIT_LOG"
    ;;
  drill_fields: [company_purchase_order_audit_log_id]

  dimension: company_purchase_order_audit_log_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_PURCHASE_ORDER_AUDIT_LOG_ID" ;;
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

  dimension: action {
    type: string
    sql: ${TABLE}."ACTION" ;;
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

  dimension: parameters {
    type: string
    sql: ${TABLE}."PARAMETERS" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: company_purchase_order_line_item_id {
    type: number
    sql:  ${TABLE}."PARAMETERS":company_purchase_order_line_item_id ;;
  }

  dimension: company_purchase_order_id {
    type: number
    sql:  ${TABLE}."PARAMETERS":company_purchase_order_id ;;
  }

  dimension: new_net_price {
    type: number
    sql:  ${TABLE}."PARAMETERS":changes:net_price ;;
  }

  dimension: new_note {
    type: string
    sql:  ${TABLE}."PARAMETERS":changes:note ;;
  }

  measure: count {
    type: count
    drill_fields: [company_purchase_order_audit_log_id]
  }
}
