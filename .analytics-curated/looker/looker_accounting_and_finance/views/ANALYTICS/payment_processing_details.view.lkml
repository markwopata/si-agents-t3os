view: payment_processing_details {
  sql_table_name: "ANALYTICS"."TREASURY"."PAYMENT_PROCESSING_DETAILS" ;;

########## DIMENSIONS ##########

  dimension: bank_account_name {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT_NAME" ;;
  }

  dimension: branch_corporate {
    label: "Payment Location"
    type: string
    sql: ${TABLE}."BRANCH_CORPORATE" ;;
  }

  dimension: payment_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PAYMENT_BRANCH_ID" ;;
  }

  dimension: payment_branch_name {
    type: string
    sql: ${TABLE}."PAYMENT_BRANCH_NAME" ;;
  }

  dimension: invoice_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVOICE_BRANCH_ID" ;;
  }

  dimension: invoice_branch_name {
    type: string
    sql: ${TABLE}."INVOICE_BRANCH_NAME" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: created_by_user_id {
    type: string
    value_format_name: id
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: created_by_email_address {
    type: string
    sql: ${TABLE}."CREATED_BY_EMAIL_ADDRESS" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: entered_as_prepayment {
    type: yesno
    sql: ${TABLE}."ENTERED_AS_PREPAYMENT" ;;
  }


  dimension: invoice_no {
    label: "Invoice NO"
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: method {
    type: string
    sql: ${TABLE}."METHOD" ;;
  }


  dimension: payment_id {
    type: number
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/payments/{{ value }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."PAYMENT_METHOD" ;;
  }

  dimension: payment_processeor {
    label: "Payment Processor"
    type: string
    sql: ${TABLE}."PAYMENT_PROCESSOR" ;;
  }

  dimension: stripe_id {
    type: string
    sql: ${TABLE}."STRIPE_ID" ;;
  }

  dimension: exempt_from_fee {
    type: string
    sql: ${TABLE}."EXEMPT_FROM_FEE" ;;
  }

  ########## DATES ##########

  dimension_group: payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  ########## MEASURES ##########

  measure: applied_payment_amount {
    type: sum
    value_format_name: usd
    drill_fields: [payment_details*]
    sql: ${TABLE}."APPLIED_PAYMENT_AMOUNT" ;;
  }

  measure: payment_count {
    type: count
    value_format_name: decimal_0
    drill_fields: [payment_details*]
  }

  ########## DRILL FIELDS ##########


  set: payment_details {
    fields: [payment_id,payment_date,invoice_no,customer_id,customer_name,exempt_from_fee,payment_branch_id,payment_branch_name,invoice_branch_id,
      invoice_branch_name,payment_method,bank_account_name,stripe_id,reference,created_by_user_id,created_by_email_address,payment_processeor,method,applied_payment_amount]
  }

}
