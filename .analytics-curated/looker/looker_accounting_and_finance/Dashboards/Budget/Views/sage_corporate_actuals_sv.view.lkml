view: sage_corporate_actuals_sv {
  sql_table_name: "ANALYTICS"."EXTERNAL_SHARING"."SAGE_CORPORATE_ACTUALS_SV"
    ;;

  dimension: amount_credit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
  }

  dimension: amount_currency {
    type: string
    sql: ${TABLE}."AMOUNT_CURRENCY" ;;
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
  }

  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
  }

  dimension: approver_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."APPROVER_ID" ;;
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  dimension: batch_number {
    value_format_name: id
    type: number
    sql: ${TABLE}."BATCH_NUMBER" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: cm_bank_id {
    type: string
    sql: ${TABLE}."CM_BANK_ID" ;;
  }

  dimension: cm_deposit_id {
    type: string
    sql: ${TABLE}."CM_DEPOSIT_ID" ;;
  }

  dimension: cm_description_1 {
    type: string
    sql: ${TABLE}."CM_DESCRIPTION_1" ;;
  }

  dimension: cm_description_2 {
    type: string
    sql: ${TABLE}."CM_DESCRIPTION_2" ;;
  }

  dimension: cm_pay_method {
    type: string
    sql: ${TABLE}."CM_PAY_METHOD" ;;
  }

  dimension: cm_state {
    type: string
    sql: ${TABLE}."CM_STATE" ;;
  }

  dimension: cm_transaction_type {
    type: string
    sql: ${TABLE}."CM_TRANSACTION_TYPE" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: expense_line_id {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: expense_line_name {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_NAME" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: gl_name {
    type: string
    sql: ${TABLE}."GL_NAME" ;;
  }

  dimension: glbatch_recordno {
    value_format_name: id
    type: number
    sql: ${TABLE}."GLBATCH_RECORDNO" ;;
  }

  dimension: glentry_recordno {
    value_format_name: id
    type: number
    sql: ${TABLE}."GLENTRY_RECORDNO" ;;
  }

  dimension: glresolve_recordno {
    type: string
    sql: ${TABLE}."GLRESOLVE_RECORDNO" ;;
  }

  dimension: header_memo {
    type: string
    sql: ${TABLE}."HEADER_MEMO" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: originator_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."ORIGINATOR_ID" ;;
  }

  dimension: originator_name {
    type: string
    sql: ${TABLE}."ORIGINATOR_NAME" ;;
  }

  dimension_group: post {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}."RECORD_TYPE" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: sub_department_id {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: sub_department_name {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;
  }

  dimension: submitter_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."SUBMITTER_ID" ;;
  }

  dimension: submitter_name {
    type: string
    sql: ${TABLE}."SUBMITTER_NAME" ;;
  }

  dimension: trx_credit {
    type: number
    sql: ${TABLE}."TRX_CREDIT" ;;
  }

  dimension: trx_currency {
    type: string
    sql: ${TABLE}."TRX_CURRENCY" ;;
  }

  dimension: trx_debit {
    type: number
    sql: ${TABLE}."TRX_DEBIT" ;;
  }

  dimension: trx_net {
    type: number
    sql: ${TABLE}."TRX_NET" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      customer_name,
      approver_name,
      submitter_name,
      expense_line_name,
      originator_name,
      vendor_name,
      sub_department_name,
      gl_name
    ]
  }
}
