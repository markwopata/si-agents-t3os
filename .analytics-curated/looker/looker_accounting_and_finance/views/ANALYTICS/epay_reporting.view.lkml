view: epay_reporting {
  sql_table_name: "ANALYTICS"."PL_DBT"."GOLD_EPAY_REPORTING" ;;

############## DIMENSIONS ##############



  dimension: key {
    type: string
    primary_key: yes
    sql: ${vendor_id}||'-'||${bill_number}||'-'||${doc_check_no} ;;
  }

  dimension: alt_pay_method {
    type: string
    sql: ${TABLE}."ALT_PAY_METHOD" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: doc_check_no {
    type: string
    sql: ${TABLE}."DOC_CHECK_NO" ;;
  }

  dimension: is_epay {
    type: number
    sql: ${TABLE}."IS_EPAY" ;;
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

  ############## DATES ##############
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

  dimension: first_set_month {
    type: string
    sql: ${TABLE}."FIRST_SET_MONTH" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_month {
    type: string
    sql: ${TABLE}."PAYMENT_MONTH" ;;
  }

  dimension_group: month {
    type: time
    timeframes: [month]
    sql:  last_day(${payment_date}::date) ;;
  }

  dimension: payment_amount_dim {
    type: number
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  ############## MEASURES ##############

  measure: transaction_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [epay_details*]
    sql: ${doc_check_no} ;;
  }

  measure: bill_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [bill_details*]
    sql: ${bill_number} ;;
  }

  measure: vendor_count {
    type: count_distinct
    value_format_name: decimal_0
    drill_fields: [epay_details*]
    sql: ${vendor_id} ;;
  }

  measure: bill_amount {
    type: sum
    value_format_name: usd_0
    drill_fields: [epay_details*]
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  measure: average_payment_amount {
    type: number
    value_format_name: usd
    drill_fields: [epay_details*]
    sql: case when ${transaction_count}>0 then ${payment_amount}/${transaction_count}
      else 0 end ;;
  }

  measure: outstanding_amount {
    type: sum
    value_format_name: usd_0
    drill_fields: [epay_details*]
    sql: ${TABLE}."OUTSTANDING_AMOUNT" ;;
  }

  measure: payment_amount {
    type:sum
    value_format_name: usd
    drill_fields: [epay_details*]
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  measure: rebate_accrued {
    type: sum
    value_format_name: usd
    drill_fields: [epay_details*]
    sql: ${TABLE}."REBATE_ACCRUED" ;;
  }

  measure: rebate_rate {
    label: "Standard Rebate Rate"
    type: min
    value_format_name: percent_2
    drill_fields: [epay_details*]
    sql: 0.015 ;;
  }

  measure: average_working_capital_benefit  {
    type: number
    value_format_name: usd_0
    drill_fields: [epay_details*]
    sql: (${payment_amount} * .0467 * 25)/365 ;;
  }



  ############## DRILL FIELDS ##############
  set: epay_details {
    fields: [vendor_id,vendor_name,vendor_category,term_due_date_deduction,
      bill_number,alt_pay_method,bill_due_date,first_set_date,payment_date,
      first_set_date,doc_check_no,bill_amount,payment_amount,rebate_accrued]
  }

  set: bill_details {
    fields: [vendor_id,vendor_name,vendor_category,term_due_date_deduction,
      bill_number,alt_pay_method,bill_due_date,first_set_date,
      first_set_date,doc_check_no,bill_amount,payment_amount,rebate_accrued]
  }

}
