view: costentory__po_audit_log {
  sql_table_name: "COSTENTORY_GOLD"."COSTENTORY__PO_AUDIT_LOG" ;;

  dimension: pk_audit_log_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_AUDIT_LOG_ID" ;;
  }

  dimension: fk_event_log_id {
    type: string
    sql: ${TABLE}."FK_EVENT_LOG_ID" ;;
  }

  dimension: name_event_type {
    type: string
    sql: ${TABLE}."NAME_EVENT_TYPE" ;;
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
    value_format_name: id
  }

  dimension: change_group {
    type: string
    sql: ${TABLE}."CHANGE_GROUP" ;;
  }

  dimension: change_key {
    type: string
    sql: ${TABLE}."CHANGE_KEY" ;;
  }

  dimension: before_value {
    type: string
    sql: ${TABLE}."BEFORE_VALUE" ;;
  }

  dimension: after_value {
    type: string
    sql: ${TABLE}."AFTER_VALUE" ;;
  }

  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }

  dimension: email_created_by {
    type: string
    sql: ${TABLE}."EMAIL_CREATED_BY" ;;
  }

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd
  }

  dimension: currency_code {
    type: string
    sql: ${TABLE}."CURRENCY_CODE" ;;
  }

  dimension: promise_date_before {
    type: string
    sql: ${TABLE}."PROMISE_DATE_BEFORE" ;;
  }

  dimension: promise_date_after {
    type: string
    sql: ${TABLE}."PROMISE_DATE_AFTER" ;;
  }

  dimension: fk_purchase_order_id {
    type: string
    sql: ${TABLE}."FK_PURCHASE_ORDER_ID" ;;
  }

  dimension: fk_line_item_id {
    type: string
    sql: ${TABLE}."FK_LINE_ITEM_ID" ;;
  }

  dimension: fk_created_by_user_id {
    type: string
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }

  dimension: fk_receiver_id {
    type: string
    sql: ${TABLE}."FK_RECEIVER_ID" ;;
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  measure: count {
    type: count
  }
}
