view: customers_over_credit_limit {
  sql_table_name: "ANALYTICS"."TREASURY"."CUSTOMERS_OVER_CREDIT_LIMIT" ;;

####### DIMENSIONS #######

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

  dimension: aging_bucket {
    type: string
    sql: ${TABLE}."AGING_BUCKET" ;;
  }

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: customer_id {
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/companies/{{ customers_over_credit_limit.customer_id }}" target="_blank">{{ value }}</a></font></u>;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: credit_limit {
    value_format_name: usd
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: invoice_no {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{ value }}</a></font></u>;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }

  ####### MEASURE #######

  measure: billed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: owed_amount {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }


  ####### DRILL FIELDS #######
  set: trx_details {
    fields: [customer_name,customer_id,terms,credit_limit,invoice_no,billing_approved_date,due_date,age,aging_bucket,billed_amount,owed_amount]
  }

}
