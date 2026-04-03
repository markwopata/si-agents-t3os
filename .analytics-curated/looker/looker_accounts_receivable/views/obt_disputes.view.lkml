view: obt_disputes {
  sql_table_name: "INTACCT_MODELS"."OBT_DISPUTES" ;;

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: dispute_category {
    type: string
    sql: ${TABLE}."DISPUTE_CATEGORY" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: do_not_rent_flag {
    type: string
    sql: ${TABLE}."DO_NOT_RENT_FLAG" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: days_to_resolve {
    type: number
    sql: ${TABLE}."DAYS_TO_RESOLVE" ;;
  }
  dimension: dispute_id {
    type: string
    sql: ${TABLE}."DISPUTE_ID" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
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

  dimension_group: dispute_date_creation {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DISPUTE_DATE_CREATION" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension_group: last_customer_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_CUSTOMER_PAYMENT_DATE" ;;
  }
  dimension: url_admin {


      label: "Admin URL"
      html: <a style="color:blue" href="{{url_admin._value}}" target="_blank">{{value}}</a> ;;
      sql: ${TABLE}."URL_ADMIN" ;;
    }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
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
    drill_fields: [customer_name]
  }
}
