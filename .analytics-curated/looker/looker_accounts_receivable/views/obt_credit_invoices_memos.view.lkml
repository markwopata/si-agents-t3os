view: obt_credit_invoices_memos {
  sql_table_name: "INTACCT_MODELS"."OBT_CREDIT_INVOICES_MEMOS" ;;
  dimension: amount_overextended {
    type: number
    sql: ${TABLE}."AMOUNT_OVEREXTENDED" ;;
    value_format: "$#,##0.00"

  }
  dimension: credit_limit {
    type: number
    sql: ${TABLE}."CREDIT_LIMIT" ;;
    value_format: "$#.##"
  }
  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }
  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: created_by_user {
    type: string
    sql: ${TABLE}."CREATED_BY_USER" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }
  dimension: days_past_due_category {
    type: string
    sql: ${TABLE}."DAYS_PAST_DUE_CATEGORY" ;;
  }

  dimension: customer_credit_category {
    type: string
    sql: ${TABLE}."CUSTOMER_CREDIT_CATEGORY" ;;
  }

  dimension: paid_count_invoices {
    type: string
    sql: ${TABLE}."PAID_COUNT_INVOICES" ;;
  }

  dimension: not_due_yet_count_invoices {
    type: string
    sql: ${TABLE}."NOT_DUE_YET_COUNT_INVOICES" ;;
  }

  dimension: _31_60_days_past_due_count_invoices {
    type: string
    sql: ${TABLE}."_31_60_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }

  dimension: _61_90_days_past_due_count_invoices {
    type: string
    sql: ${TABLE}."_61_90_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }

  dimension: _91_120_days_past_due_count_invoices {
    type: string
    sql: ${TABLE}."_91_120_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }

  dimension: _120_past_due_count_invoices {
    type: string
    sql: ${TABLE}."_120_DAYS_PAST_DUE_COUNT_INVOICES" ;;
  }

  dimension: paid_amount_invoices {
    type: string
    sql: ${TABLE}."PAID_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }

  dimension: not_due_yet_amount_invoices {
    type: string
    sql: ${TABLE}."NOT_DUE_YET_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }

  dimension: _31_60_days_past_due_amount_invoices {
    type: string
    sql: ${TABLE}."_31_60_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"


  }
  dimension: _61_90_days_past_due_amount_invoices {
    type: string
    sql: ${TABLE}."_61_90_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: _91_120_days_past_due_amount_invoices {
    type: string
    sql: ${TABLE}."_91_120_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: _120_past_due_amount_invoices {
    type: string
    sql: ${TABLE}."_120_DAYS_PAST_DUE_AMOUNT_INVOICES" ;;
    value_format: "$#,##0.00"

  }
  dimension: do_not_rent_flag {
    type: string
    sql: ${TABLE}."DO_NOT_RENT_FLAG" ;;
  }
  dimension: is_do_not_rent {
    type: string
    sql: ${TABLE}."IS_DO_NOT_RENT" ;;
  }
  dimension: list_of_salespersons {
    type: string
    sql: ${TABLE}."LIST_OF_SALESPERSONS" ;;
  }

  dimension: list_of_salespersons_id {
    type: string
    sql: ${TABLE}."LIST_OF_SALESPERSONS_ID" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: district_number {
    type: string
    sql: ${TABLE}."DISTRICT_NUMBER" ;;
  }
  dimension: customer_total_balance_owed {
    type: string
    sql: ${TABLE}."CUSTOMER_TOTAL_BALANCE_OWED" ;;
    value_format: "$#,##0.00"
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
