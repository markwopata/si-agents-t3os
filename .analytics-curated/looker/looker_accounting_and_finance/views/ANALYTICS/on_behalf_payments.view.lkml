view: on_behalf_payments {
  sql_table_name: "ANALYTICS"."TREASURY"."ON_BEHALF_PAYMENTS" ;;

############# DIMENSIONS #############

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: customer_id {
  label: "Customer ID"
  value_format_name: id
   type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ on_behalf_payments.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: deposit_to {
    type: string
    sql: ${TABLE}."DEPOSIT_TO" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension_group: payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYMENT_DATE" ;;
  }

  dimension: payment_id {
    value_format_name: id
    type: number
    html: <a href= "https://admin.equipmentshare.com/#/home/payments/{{ value }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."PAYMENT_ID" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: payment_type {
    type: string
    sql: ${TABLE}."PAYMENT_TYPE" ;;
  }

  dimension: posted {
    type: string
    sql: ${TABLE}."POSTED" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: payment_amount {
    value_format_name: usd
    type: number
    sql: ${TABLE}."PAYMENT_AMOUNT" ;;
  }

  dimension: amount_remaining {
    value_format_name: usd
    type: number
    sql: ${TABLE}."AMOUNT_REMAINING" ;;
  }

}
