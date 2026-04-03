view: credit_fraud {
  sql_table_name: "ANALYTICS"."TREASURY"."CREDIT_FRAUD" ;;


##### DIMENSIONS #####

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: credit_note {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."CREDIT_NOTE_DATE" ;;
  }

  dimension: credit_note_number {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/credit-notes/search?query={{ value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CREDIT_NOTE_NUMBER" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ credit_fraud.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: final_collector {
    type: string
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: indicator {
    type: string
    sql: ${TABLE}."INDICATOR" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  ##### MEASURES #####

  measure: account_balance {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."ACCOUNT_BALANCE" ;;
  }

  measure: billed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: remaining_credit_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
  }

  measure: total_credit_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
  }

}
