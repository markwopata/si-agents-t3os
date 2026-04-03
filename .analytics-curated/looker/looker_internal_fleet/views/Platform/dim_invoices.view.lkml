view: dim_invoices {
  sql_table_name: "PLATFORM"."GOLD"."DIM_INVOICES" ;;

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
  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: invoice_id_with_admin_link {
    type: number
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{invoice_id}}" target="_blank">{{invoice_id._value }}</a></font></u> ;;
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
