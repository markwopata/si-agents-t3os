view: unsubmitted_invoices_db {
  sql_table_name: "CONCUR"."UNSUBMITTED_INVOICES_DB" ;;

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
  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }
  dimension_group: due {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DUE_DATE" ;;
  }
  dimension: employee_email_address {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" ;;
  }
  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME" ;;
  }
  dimension: inventory_reporting_category {
    type: string
    sql: ${TABLE}."INVENTORY_REPORTING_CATEGORY" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension_group: invoice_receieved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_RECEIEVED_DATE" ;;
  }
  dimension: invoice_received {
    type: string
    sql: ${TABLE}."INVOICE_RECEIVED" ;;
  }
  dimension: invoice_received_date {
    type: string
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
  dimension: past_due_bucket {
    type: string
    sql: ${TABLE}."PAST_DUE_BUCKET" ;;
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
  dimension: request_name {
    type: string
    sql: ${TABLE}."REQUEST_NAME" ;;
  }
  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }
  dimension: revised_terms {
    type: number
    sql: ${TABLE}."REVISED_TERMS" ;;
  }
  dimension: service_type {
    type: string
    sql: ${TABLE}."SERVICE_TYPE" ;;
  }
  dimension_group: submit {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [request_name, supplier_name, vendor_name, employee_last_name, custom_1_name]
  }
}
