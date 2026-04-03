view: concur_not_submitted_invoice_and_detail {
  derived_table: {
    sql: SELECT
          i.*,
          id.CREATED_DATE,
          id.UPDATED_DATE,
          id.VENDOR_ID,
          id.VENDOR_INVOICE_NUMBER,
          id.CURRENT_STATE,
          id.ASSIGNED_TO,
          id.MARKET_ID,
          id.EXPENSE_TYPE_CODE,
          id.REQUESTED_AMOUNT,
          id.SHIPPING_AMOUNT,
          id.TAX_AMOUNT

      FROM "ANALYTICS"."CONCUR"."INVOICE_HEADER" i
      LEFT JOIN "ANALYTICS"."CONCUR"."INVOICE_DETAIL" id
      ON i.request_id = id.request_id

      WHERE APPROVAL_STATUS = 'Not Submitted'
      AND PAYMENT_STATUS = 'Not Paid'
      ;;
  }

  measure: count {
    type: count
    link: {
      label: "Detail View"
      url: "https://equipmentshare.looker.com/dashboards/652"
    }
    drill_fields: []
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: request_name {
    type: string
    sql: ${TABLE}."REQUEST_NAME" ;;
  }

  dimension: supplier_code {
    type: string
    sql: ${TABLE}."SUPPLIER_CODE" ;;
  }

  dimension: supplier_name {
    type: string
    sql: ${TABLE}."SUPPLIER_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: employee_email_address {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_ADDRESS" ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  dimension: request_key {
    type: number
    sql: ${TABLE}."REQUEST_KEY" ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: exception_count {
    type: number
    sql: ${TABLE}."EXCEPTION_COUNT" ;;
  }

  dimension: cleared_exception_count {
    type: number
    sql: ${TABLE}."CLEARED_EXCEPTION_COUNT" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}."CREATED_DATE" ;;
  }

  dimension_group: updated_date {
    type: time
    sql: ${TABLE}."UPDATED_DATE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_invoice_number {
    type: string
    sql: ${TABLE}."VENDOR_INVOICE_NUMBER" ;;
  }

  dimension: current_state {
    type: string
    sql: ${TABLE}."CURRENT_STATE" ;;
  }

  dimension: assigned_to {
    type: string
    sql: ${TABLE}."ASSIGNED_TO" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: expense_type_code {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE_CODE" ;;
  }

  dimension: requested_amount {
    type: number
    sql: ${TABLE}."REQUESTED_AMOUNT" ;;
  }

  dimension: shipping_amount {
    type: number
    sql: ${TABLE}."SHIPPING_AMOUNT" ;;
  }

  dimension: tax_amount {
    type: number
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  set: detail {
    fields: [
      request_id,
      request_name,
      supplier_code,
      supplier_name,
      invoice_number,
      purchase_order_number,
      employee_email_address,
      request_total,
      request_key,
      approval_status,
      payment_status,
      exception_count,
      cleared_exception_count,
      _es_update_timestamp_time,
      created_date,
      updated_date_time,
      vendor_id,
      vendor_invoice_number,
      current_state,
      assigned_to,
      market_id,
      expense_type_code,
      requested_amount,
      shipping_amount,
      tax_amount
    ]
  }
}
