view: training_invoices {
  sql_table_name: "ANALYTICS"."TREASURY"."TRAINING_INVOICES" ;;

##### DIMENSIONS #####

  dimension: branch_id {
    label: "Branch ID"
    type: number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: created_by_user {
    type: string
    sql: ${TABLE}."CREATED_BY_USER" ;;
  }

  dimension: customer_id {
    label: "Customer ID"
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ training_invoices.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }

  dimension_group: due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_no {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}&includeDeletedInvoices=false" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension_group: paid {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAID_DATE" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  ##### MEASURES #####

  measure: billed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."BILLED_AMOUNT" ;;
  }

  measure: owed_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  measure: paid_amount {
    value_format_name: usd
    type: sum
    sql: ${TABLE}."PAID_AMOUNT" ;;
  }

}
