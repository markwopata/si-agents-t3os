view: unsubmitted_invoices {
  sql_table_name: "ANALYTICS"."CONCUR"."UNSUBMITTED_INVOICES" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }
  dimension_group: cognos {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COGNOS_DATE" ;;
  }
  dimension: custom_1_location {
    type: string
    sql: ${TABLE}."CUSTOM_1_LOCATION" ;;
  }
  dimension: custom_1_name {
    type: string
    sql: ${TABLE}."CUSTOM_1_NAME" ;;
  }
  dimension: employee_email_address {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" ;;
  }
  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_received {
    type: string
    sql: ${TABLE}."INVOICE_RECEIVED" ;;
  }
  dimension_group: invoice_received {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;
  }
  dimension: non_inventory {
    type: string
    sql: ${TABLE}."NON_INVENTORY" ;;
  }
  dimension: origin_source {
    type: string
    sql: ${TABLE}."ORIGIN_SOURCE" ;;
  }
  dimension_group: payment_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }
  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }
  dimension: policy {
    type: string
    sql: ${TABLE}."POLICY" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }
  dimension: request_name {
    type: string
    sql: ${TABLE}."REQUEST_NAME" ;;
  }
  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }
  dimension: submit_date {
    type: string
    sql: ${TABLE}."SUBMIT_DATE" ;;
  }
  dimension: supplier_code {
    type: string
    sql: ${TABLE}."SUPPLIER_CODE" ;;
  }
  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}."SUPPLIER_INVOICE_NUMBER" ;;
  }
  dimension: supplier_name {
    type: string
    sql: ${TABLE}."SUPPLIER_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [supplier_name, custom_1_name, request_name, employee_last_name]
  }
}
