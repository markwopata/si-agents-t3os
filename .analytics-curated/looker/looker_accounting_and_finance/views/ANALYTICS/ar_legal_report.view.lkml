view: ar_legal_report {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_LEGAL_REPORT" ;;

  ############# DIMENSIONS #############

  dimension: billing_approved_date {
    type: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: billing_approved_year {
    type: string
    value_format_name: id
    sql: year(${TABLE}."BILLING_APPROVED_DATE") ;;
  }

  dimension: last_payment_date {
    type: date
    sql: ${TABLE}."LAST_PAYMENT_DATE" ;;
  }

  dimension: city {
    type: string
    sql: coalesce(${TABLE}."CITY",'') ;;
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

  dimension: invoice_no {
    type: string
    html: <a href='https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value | url_encode }}' target='_blank' style='color: blue; text-decoration: underline;'>{{ value | url_encode }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
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

  dimension: state {
    type: string
    sql: coalesce(${TABLE}."STATE",'') ;;
  }

  dimension: street_1 {
    type: string
    sql: coalesce(${TABLE}."STREET_1",'') ;;
  }

  dimension: street_2 {
    type: string
    sql: coalesce(${TABLE}."STREET_2",'') ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: coalesce(${TABLE}."ZIP_CODE",'') ;;
  }


  dimension: address {
    type: string
    sql: ${street_1}||' '||${street_2}||' ' ||${city} || ', ' || ${state} || ' ' || ${zip_code};;
  }

  ############# MEASURES #############

  measure: invoice_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
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
    sql: ${TABLE}."PAID_AMOUNT" ;;
  }

  measure: credit_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
  }

  measure: open_credits {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."OPEN_CREDITS" ;;
  }

  measure: credit_amount_paid {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."CREDIT_AMOUNT_PAID" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd
    drill_fields: [ar_details*]
    sql: ${TABLE}."REVENUE" ;;
  }

############## DRILL FIELDS ##############

  set: ar_details {
    fields: [invoice_no,customer_name,customer_id,collector,billing_approved_date,invoice_amount,last_payment_date,balance_due,credit_amount,open_credits,revenue]
  }



}
