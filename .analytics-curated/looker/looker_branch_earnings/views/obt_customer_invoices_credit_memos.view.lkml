view: obt_customer_invoices_credit_memos {
  sql_table_name: "INTACCT_MODELS"."OBT_CUSTOMER_INVOICES_CREDIT_MEMOS" ;;

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }
  dimension_group: credit_note_creation {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREDIT_NOTE_CREATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: credit_note_number {
    label: "CN Number"
    html: <a style="color:blue" href="{{url_credit_note_admin._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}."CREDIT_NOTE_NUMBER";;

  }

  dimension: remaining_credit_amount {
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
    value_format: "$#,##0.00"

  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: district_number {
    type: string
    sql: ${TABLE}."DISTRICT_NUMBER" ;;
  }
  dimension: do_not_rent_flag {
    type: string
    sql: ${TABLE}."DO_NOT_RENT_FLAG" ;;
  }
  dimension: invoice_amount {
    type: number
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
    value_format: "$#,##0.00"

  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    label: "Invoice Number"
    html: <a style="color:blue" href="{{url_admin._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}."INVOICE_NUMBER";;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: num_days_between_invoice_credit_date {
    type: number
    sql: ${TABLE}."NUM_DAYS_BETWEEN_INVOICE_CREDIT_DATE" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: total_credit_amount {
    type: number
    sql: ${TABLE}."TOTAL_CREDIT_AMOUNT" ;;
    value_format: "$#,##0.00"

  }
  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }
  dimension: url_credit_note_admin {
    type: string
    sql: ${TABLE}."URL_CREDIT_NOTE_ADMIN" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, customer_name, region_name]
  }
}
