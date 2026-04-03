view: v_invoices {
  sql_table_name: "PLATFORM"."GOLD"."V_INVOICES" ;;

  dimension: invoice_avalara_transaction_id {
    type: string
    sql: ${TABLE}."INVOICE_AVALARA_TRANSACTION_ID" ;;
  }
  dimension: invoice_billing_approved {
    type: yesno
    sql: ${TABLE}."INVOICE_BILLING_APPROVED" ;;
  }
  dimension: invoice_customer_tax_exempt_status {
    type: yesno
    sql: ${TABLE}."INVOICE_CUSTOMER_TAX_EXEMPT_STATUS" ;;
  }
  dimension: invoice_deleted_flag {
    type: yesno
    sql: ${TABLE}."INVOICE_DELETED_FLAG" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_key {
    type: string
    sql: ${TABLE}."INVOICE_KEY" ;;
  }
  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }
  dimension: invoice_number_of_days_outstanding {
    type: number
    sql: ${TABLE}."INVOICE_NUMBER_OF_DAYS_OUTSTANDING" ;;
  }
  dimension: invoice_paid {
    type: yesno
    sql: ${TABLE}."INVOICE_PAID" ;;
  }
  dimension_group: invoice_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."INVOICE_RECORDTIMESTAMP" ;;
  }
  dimension: invoice_reference {
    type: string
    sql: ${TABLE}."INVOICE_REFERENCE" ;;
  }
  dimension: invoice_source {
    type: string
    sql: ${TABLE}."INVOICE_SOURCE" ;;
  }
  measure: count {
    type: count
  }
}
