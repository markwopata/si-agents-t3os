view: cod_report {
  sql_table_name: "ANALYTICS"."TREASURY"."COD_REPORT" ;;

  ########## DIMENSIONS ##########

  dimension: aging_buckets {
    type: string
    sql: ${TABLE}."AGING_BUCKETS" ;;
  }

  dimension: aging_days {
    type: number
    sql: ${TABLE}."AGING_DAYS" ;;
  }


  dimension: billing_approved_date {
    type: date
    sql: CAST(${TABLE}."BILLING_APPROVED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: billing_approved_year {
    type: number
    sql: ${TABLE}."BILLING_APPROVED_YEAR" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: customer_id {
    type: number
    value_format_name: id
    #html: <a href='https://equipmentshare.looker.com/dashboards/1263?Customer+ID={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: date_opened {
    type: date
    convert_tz: no
    sql: ${TABLE}."DATE_OPENED" ;;
  }

  dimension: due_date {
    type: date
    sql: CAST(${TABLE}."DUE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: paid_date {
    type: date
    sql: CAST(${TABLE}."PAID_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: payment_terms {
    type: string
    sql: ${TABLE}."PAYMENT_TERMS" ;;
  }

  dimension: salesperson_email_address {
    type: string
    sql: ${TABLE}."SALESPERSON_EMAIL_ADDRESS" ;;
  }

  dimension: salesperson_name {
    type: string
    sql: ${TABLE}."SALESPERSON_NAME" ;;
  }

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }


  ########## MEASURES ##########

  measure: bad_debt {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."BAD_DEBT" ;;
  }

  measure: balance_due {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."BALANCE_DUE" ;;
  }

  measure: paid_amount {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."PAID_AMOUNT" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: invoice_amount {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
  }

  ########## DRILL FIELDS ##########
  set: ar_details {
    fields: [invoice_no,customer_name,customer_id,payment_terms,collector,invoice_amount,revenue,balance_due,bad_debt]
  }



}
