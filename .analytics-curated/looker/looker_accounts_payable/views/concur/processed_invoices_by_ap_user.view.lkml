view: processed_invoices_by_ap_user {
  sql_table_name: "CONCUR"."PROCESSED_INVOICES_BY_AP_USER" ;;




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
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: payment_method_type {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD_TYPE" ;;
  }
  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }
  dimension: request_currency {
    type: string
    sql: ${TABLE}."REQUEST_CURRENCY" ;;
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
  dimension: requesting_employee {
    type: string
    sql: ${TABLE}."REQUESTING_EMPLOYEE" ;;
  }
  dimension_group: submit {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."SUBMIT_DATE" ;;
  }
  dimension: submitter {
    type: string
    sql: ${TABLE}."SUBMITTER" ;;
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
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      request_id,
      request_name,
      approval_status,
      cognos_date,
      description,
      employee_id,
      invoice_date,
      payment_method_type,
      purchase_order_number,
      request_currency,
      request_total,
      requesting_employee,
      submit_date,
      submitter,
      supplier_invoice_number,
      supplier_name


    ]
}

}
