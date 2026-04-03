view: obt_credit_invoices_memos {
  sql_table_name: "INTACCT_MODELS"."OBT_CREDIT_INVOICES_MEMOS" ;;

  dimension: _120_days_past_due_amount_invoices {
    type: number
    sql: ${TABLE}."_120_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"
    }
  dimension: _120_days_past_due_count_invoices {
    type: number
    sql: ${TABLE}."_120_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }
  dimension: _31_60_days_past_due_amount_invoices {
    type: number
    sql: ${TABLE}."_31_60_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: _31_60_days_past_due_count_invoices {
    type: number
    sql: ${TABLE}."_31_60_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }
  dimension: _61_90_days_past_due_amount_invoices {
    type: number
    sql: ${TABLE}."_61_90_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: _61_90_days_past_due_count_invoices {
    type: number
    sql: ${TABLE}."_61_90_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }
  dimension: _91_120_days_past_due_amount_invoices {
    type: number
    sql: ${TABLE}."_91_120_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: _91_120_days_past_due_count_invoices {
    type: number
    sql: ${TABLE}."_91_120_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }
  dimension: amount_overextended {
    type: number
    sql: ${TABLE}."AMOUNT_OVEREXTENDED" ;;
    value_format: "$#,##0.00"

  }
  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }
  dimension: created_by_user {
    type: string
    sql: ${TABLE}."CREATED_BY_USER" ;;
  }
  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
    value_format: "$#,##0.00"

  }
  dimension: customer_credit_category {
    type: string
    sql: ${TABLE}."CUSTOMER_CREDIT_CATEGORY" ;;
  }
  dimension: customer_id {
    label: "Customer ID"
    html: <a style="color:blue" href="{{url_admin._value}}" target="_blank">{{value}}</a> ;;
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: customer_total_balance_owed {
    type: number
    sql: ${TABLE}."CUSTOMER_TOTAL_BALANCE_OWED" ;;
    value_format: "$#,##0.00"

  }
  dimension: district_number {
    type: string
    sql: ${TABLE}."DISTRICT_NUMBER" ;;
  }
  dimension: do_not_rent_flag {
    type: string
    sql: ${TABLE}."DO_NOT_RENT_FLAG" ;;
  }
  dimension_group: last_customer_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_CUSTOMER_PAYMENT_DATE" ;;
  }
  dimension: list_of_salespersons {
    type: string
    sql: ${TABLE}."LIST_OF_SALESPERSONS" ;;
  }
  dimension: list_of_salespersons_id {
    type: string
    sql: ${TABLE}."LIST_OF_SALESPERSONS_ID" ;;
  }
  dimension: market_id {
    type: number
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
  dimension: current_amount_invoices {
    type: number
    sql: ${TABLE}."CURRENT_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

}
  dimension: current_count_invoices {
    type: number
    sql: ${TABLE}."CURRENT_COUNT_INVOICES" ;;
  }

#  dimension: paid_count_invoices {
#    type: number
#    sql: ${TABLE}."PAID_COUNT_INVOICES" ;;
#  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, customer_name, region_name]
  }
}
