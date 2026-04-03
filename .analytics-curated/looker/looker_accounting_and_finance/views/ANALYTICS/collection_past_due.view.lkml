view: collection_past_due {
  sql_table_name: "ANALYTICS"."TREASURY"."COLLECTION_PAST_DUE" ;;

####### DATES #######

  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension_group: paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  ####### DIMENSIONS #######

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: tam {
    label: "TAM"
    type: string
    sql: IFNULL(${TABLE}."TAM",'No TAM Assigned') ;;
  }

  dimension: tam_email {
    label: "TAM EMAIL"
    type: string
    sql: IFNULL(${TABLE}."TAM_EMAIL",'No TAM Assigned') ;;
  }

  dimension: customer_id {
    label: "Customer ID"
    value_format_name: id
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/companies/{{ collection_past_due.customer_id }}" target="_blank">{{value}}</a></font></u>;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: days_since_due_date {
    type: number
    sql: ${TABLE}."DAYS_SINCE_DUE_DATE" ;;
  }

  dimension: invoice_no {
    label: "Invoice Number"
    type: string
    html:<font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{ value }}</a></font></u>;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: dnr {
    label: "DNR"
    type: yesno
    sql: ${TABLE}."DNR" ;;
  }

  dimension: market_id {
    label: "Market ID"
    value_format_name: id
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: paid {
    type: yesno
    sql: ${TABLE}."PAID" ;;
  }

  dimension: balance_dim {
    value_format_name: usd
    type: number
    drill_fields: [trx_details*]
    sql: IFNULL(${TABLE}."BALANCE",0) ;;
  }

  ####### MEASURES #######

  measure: count {
    type: count
    drill_fields: [trx_details*]
  }

  measure: balance {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: IFNULL(${TABLE}."BALANCE",0) ;;
  }




  measure: paid_amount {
    value_format_name: usd
    type: sum
    drill_fields: [trx_details*]
    sql: IFNULL(${TABLE}."PAID_AMOUNT",0) ;;
  }

  measure: invoice_paid {
    value_format_name: decimal_0
    type: sum
    drill_fields: [trx_details*]
    sql: IFNULL(${TABLE}."INVOICE_PAID",0) ;;
  }

  measure: max_days_since_due_date {
    value_format_name: decimal_0
    type: max
    drill_fields: [trx_details*]
    sql: ${days_since_due_date} ;;
  }

  ####### DRILL-FIELDS #######

  set: trx_details {
    fields: [customer_name,customer_id,invoice_no,market_name,market_id,collector,manager,tam,tam_email,
      billing_approved_date,due_date,paid_date,days_since_due_date,paid_amount,balance]
  }

}
