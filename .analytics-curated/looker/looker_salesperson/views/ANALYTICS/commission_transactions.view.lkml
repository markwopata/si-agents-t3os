view: commission_transactions {
  sql_table_name: "ANALYTICS"."COMMISSION"."COMMISSION_DETAILS"
    ;;

  dimension: line_item_amount {
    type: number
    label: "Invoice Revenue"
    value_format_name: usd
    sql: ${TABLE}."LINE_ITEM_AMOUNT" ;;
  }

  dimension_group: billing_approved_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: commission_month {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."COMMISSION_MONTH" AS TIMESTAMP_NTZ) ;;
  }

  dimension: commission_percentage {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
  }

  dimension_group: dte {
    label: "Action"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DTE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: full_name {
    label: "Salesperson Full Name"
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension: hidden {
    label: "Viewable Flag"
    description: "Flag to hid transactions from statements until day before paychecks."
    type: yesno
    sql: ${TABLE}."HIDDEN" ;;
  }

  dimension: invoice_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO";;
  }

  dimension: is_finalized {
    type: yesno
    sql: ${TABLE}."IS_FINALIZED" ;;
  }

  dimension: line_item_type_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
  }

  dimension: line_item_type {
    type: string
    sql: ${TABLE}."LINE_ITEM_TYPE" ;;
  }

  dimension: commission_amount {
    type: number
    value_format_name: usd
    sql: coalesce(${TABLE}."COMMISSION_AMOUNT", 0);;
  }

  dimension_group: paycheck_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PAYCHECK_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: salesperson_type {
    case: {
      when:{
        sql: ${TABLE}."SALESPERSON_TYPE" = 1;;
        label: "Primary"
    }
    else: "Secondary"
    }
  }

  dimension: employee_type {
    label: "Employee Status"
    sql: CASE
      WHEN ${TABLE}."EMPLOYEE_TYPE" IS NOT NULL THEN ${TABLE}."EMPLOYEE_TYPE"
        ELSE 'non-salesperson'
        END;;
  }

  dimension: split {
    type: number
    value_format_name: percent_0
    sql: ${TABLE}."SPLIT" ;;
  }

  dimension: abs_split {
    label: "Commission Split"
    type: number
    value_format_name: percent_0
    sql: abs(${split}) ;;
  }

  dimension: transaction_description {
    type: string
    sql: ${TABLE}."TRANSACTION_DESCRIPTION" ;;
  }

  dimension: transaction_type {
    label: "Transaction Type"
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."USER_ID";;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: grace_period_flag {
    type: yesno
    sql: ${TABLE}."GRACE_PERIOD_FLAG" ;;
  }

  measure: commission_total {
    type: sum
    filters: [transaction_type: "commission"]
    value_format_name: usd
    sql: ${commission_amount} ;;
    drill_fields: [dte_date, transaction_description, invoices.invoice_no_with_link, line_item_amount, salesperson_type, split, commission_percentage, commission_amount, salesperson_invoice_changes.note]
  }

  measure: credits_total {
    type: sum
    filters: [transaction_type: "credit"]
    value_format_name: usd
    sql: ${commission_amount} ;;
    drill_fields: [dte_date, transaction_description, credit_notes.credit_note_with_link, commission_amount, salesperson_invoice_changes.note]
  }

  measure: clawback_total {
    type: sum
    filters: [transaction_type: "clawback"]
    value_format_name: usd
    sql: ${commission_amount} ;;
    drill_fields: [dte_date, transaction_description, invoices.invoice_no_with_link, invoices.billing_approved_date, commission_amount, salesperson_invoice_changes.note]
  }

  measure: reimbursement_total {
    type: sum
    filters: [transaction_type: "reimbursement"]
    value_format_name: usd
    sql: ${commission_amount} ;;
    drill_fields: [dte_date, transaction_description, invoices.invoice_no_with_link, credit_notes.credit_note_with_link, commission_amount]
  }

  measure: final_commission_payout {
    type: sum
    value_format_name: usd
    sql: ${commission_amount} ;;
  }

  measure: revenue_total {
    type: sum
    value_format_name: usd
    filters: [transaction_type: "commission, credit"]
    sql: ${line_item_amount}*${split} ;;
  }

  measure: salesperson_db_total {
    type: number
    value_format_name: usd
    sql: ${clawback_total} + ${reimbursement_total};;
    drill_fields: [dte_date,  companies.company_id_and_name, invoice_id, invoices.invoice_no, transaction_description, line_item_amount, abs_split, commission_amount]
  }

  measure: count {
    type: count
    drill_fields: []
  }

  set: detail {
    fields: [
      dte_date,
      transaction_description,
      commission_amount
    ]
  }
}
