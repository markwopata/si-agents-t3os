view: obt_customer_invoices_credit_memos {
  sql_table_name: "INTACCT_MODELS"."OBT_CUSTOMER_INVOICES_CREDIT_MEMOS" ;;

  dimension_group: credit_note_creation {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREDIT_NOTE_CREATION_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
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
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: created_by_user {
    type: string
    sql: ${TABLE}."CREATED_BY_USER" ;;
  }
  dimension: credit_note_invoice_number {
    type: string
    sql: ${TABLE}."CREDIT_NOTE_INVOICE_NUMBER" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: num_days_between_invoice_credit_date {
    type: number
    sql: ${TABLE}."NUM_DAYS_BETWEEN_INVOICE_CREDIT_DATE" ;;
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

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }



  dimension: is_do_not_rent {
    type: string
    sql: ${TABLE}."IS_DO_NOT_RENT" ;;
  }
  dimension: district_number {
    type: string
    sql: ${TABLE}."DISTRICT_NUMBER" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_name, market_name]
  }
}
