view: epay_reporting_summary {
  derived_table: {
    sql: SELECT VENDOR_ID,VENDOR_NAME,VENDOR_CATEGORY,TERM_DUE_DATE_DEDUCTION,
BILL_NUMBER,ALT_PAY_METHOD,BILL_DUE_DATE,FIRST_SET_DATE,PAYMENT_DATE,DOC_CHECK_NO,
BILL_AMOUNT,PAYMENT_AMOUNT,REBATE_ACCRUED,
LAST_DAY(PAYMENT_DATE::DATE) AS MONTH,
'PAYMENT' AS TYPE
FROM  ANALYTICS.PL_DBT.GOLD_EPAY_REPORTING  -- ANALYTICS.TREASURY.EPAY_REPORTING
WHERE IS_EPAY = 1
UNION ALL
SELECT VENDOR_ID,VENDOR_NAME,NULL AS VENDOR_CATEGORY,NULL AS TERM_DUE_DATE_DEDUCTION,
NULL AS BILL_NUMBER,NULL AS ALT_PAY_METHOD,NULL AS BILL_DUE_DATE,FIRST_SET_DATE,NULL AS PAYMENT_DATE,NULL AS DOC_CHECK_NO,
NULL AS BILL_AMOUNT,NULL AS PAYMENT_AMOUNT,NULL AS REBATE_ACCRUED,
LAST_DAY(FIRST_SET_DATE::DATE) AS MONTH,
'FIRST_SET' AS TYPE
FROM  ANALYTICS.PL_DBT.GOLD_EPAY_VENDOR_FIRST_SET -- ANALYTICS.TREASURY.EPAY_VENDOR_FIRST_SET
          ;;
  }

  ######## DIMENSIONS ########



  dimension: month {
    type: date
    sql: ${TABLE}.MONTH ;;
  }

  dimension_group: month {
    type: time
    timeframes: [month]
    sql: ${TABLE}.MONTH  ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: term_due_date_deduction {
    type: number
    sql: ${TABLE}."TERM_DUE_DATE_DEDUCTION" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."VENDOR_CATEGORY" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}."ALT_PAY_METHOD" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: bill_due_date {
    type: date
    sql: ${TABLE}."BILL_DUE_DATE" ;;
  }

  dimension: first_set_date {
    type: date
    sql: ${TABLE}."FIRST_SET_DATE" ;;
  }

  dimension: doc_check_no {
    type: string
    sql: ${TABLE}."DOC_CHECK_NO" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_amount_dim {
    type: number
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  ######## MEASURES ########

  measure: vendors_signed_up {
    type: count_distinct
    value_format: "#,##0;(#,##0);-"
    drill_fields: [vendor_details*]
    sql: iff(${type}='FIRST_SET',${vendor_id},null) ;;
    filters: [type: "FIRST_SET"]
  }

  measure: transactions_paid {
    type: count
    value_format: "#,##0;(#,##0);-"
    drill_fields: [transaction_details*]
    filters: [type: "PAYMENT"]
  }


  measure: invoices_paid {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [invoice_details*]
    sql: ${doc_check_no} ;;
    filters: [type: "PAYMENT"]
  }

  measure: vendors_paid {
    type: count_distinct
    value_format: "#,##0;(#,##0);-"
    drill_fields: [vendor_details*]
    sql: iff(${type}='PAYMENT',${vendor_id},null) ;;
    filters: [type: "PAYMENT"]
  }

  measure: amount_paid {
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    drill_fields: [epay_details*]
    sql:  ${payment_amount_dim} ;;
    filters: [type: "PAYMENT"]
  }

  measure: rebate_accrued {
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    drill_fields: [epay_details*]
    sql: iff(${type}='PAYMENT', ${TABLE}."REBATE_ACCRUED",0) ;;
    filters: [type: "PAYMENT"]
  }

  measure: rebate_rate {
    type: min
    value_format: "0.00%"
    sql: 0.015 ;;
  }

  measure: bill_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    drill_fields: [epay_details*]
    sql: ${TABLE}.BILL_AMOUNT ;;
  }

  measure: payment_amount {
    type: sum
    value_format: "$#,##0.00;($#,##0.00);-"
    drill_fields: [epay_details*]
    sql: ${TABLE}.PAYMENT_AMOUNT ;;
    filters: [type: "PAYMENT"]
  }

  measure: average_working_capital_benefit  {
    type: number
    value_format_name: usd
    drill_fields: [epay_details*]
    sql: (${payment_amount} * .0467 * 25)/365 ;;
  }

  ######## DRILL FIELDS ########

  set: vendor_details {
    fields: [vendor_id,vendor_name,first_set_date
    ]
  }

  set: transaction_details {
    fields: [vendor_id,vendor_name,vendor_category,term_due_date_deduction,bill_number,
      alt_pay_method,bill_due_date,payment_date,
      bill_amount,payment_amount,rebate_accrued
    ]
  }

  set: invoice_details {
    fields: [vendor_id,vendor_name,vendor_category,term_due_date_deduction,bill_number,
      alt_pay_method,bill_due_date,
      bill_amount,payment_amount,rebate_accrued
    ]
  }


  set: epay_details {
    fields: [vendor_id,vendor_name,vendor_category,term_due_date_deduction,doc_check_no,
      alt_pay_method,bill_due_date,payment_date,first_set_date,
      bill_amount,payment_amount,rebate_accrued
      ]
  }



  }
