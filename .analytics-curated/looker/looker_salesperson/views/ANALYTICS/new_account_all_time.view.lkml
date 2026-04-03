view: new_account_all_time {
  sql_table_name: "ANALYTICS"."PUBLIC"."NEW_ACCOUNT_ALL_TIME"
    ;;

  dimension: acct_with_1_k_rev {
    type: string
    sql: ${TABLE}."ACCT_WITH_1K_REV" ;;
  }

  dimension: acct_with_1_k_rev_80_rate {
    type: string
    sql: ${TABLE}."ACCT_WITH_1K_REV_80_RATE" ;;
  }

  dimension: acct_with_rev {
    type: string
    sql: ${TABLE}."ACCT_WITH_REV" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: dormant_ind {
    type: number
    sql: ${TABLE}."DORMANT_IND" ;;
  }

  dimension: final_invoice_date {
    type: string
    sql: ${TABLE}."FINAL_INVOICE_DATE" ;;
  }

  dimension: final_invoice_id {
    type: number
    sql: ${TABLE}."FINAL_INVOICE_ID" ;;
  }

  dimension: final_rental_date {
    type: string
    sql: ${TABLE}."FINAL_RENTAL_DATE" ;;
  }

  dimension: first_invoice_date {
    type: string
    sql: ${TABLE}."FIRST_INVOICE_DATE" ;;
  }

  dimension: first_invoice_id {
    type: number
    sql: ${TABLE}."FIRST_INVOICE_ID" ;;
  }

  dimension: first_rental_date {
    type: string
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }

  dimension: invoice_year_quarter {
    type: string
    sql: ${TABLE}."INVOICE_YEAR_QUARTER" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: number_of_invoices {
    type: number
    sql: ${TABLE}."NUMBER_OF_INVOICES" ;;
  }

  dimension: number_of_rentals {
    type: number
    sql: ${TABLE}."NUMBER_OF_RENTALS" ;;
  }

  dimension: perc_day_bench {
    type: number
    sql: ${TABLE}."PERC_DAY_BENCH" ;;
  }

  dimension: perc_month_bench {
    type: number
    sql: ${TABLE}."PERC_MONTH_BENCH" ;;
  }

  dimension: perc_week_bench {
    type: number
    sql: ${TABLE}."PERC_WEEK_BENCH" ;;
  }

  dimension: rental_year_quarter {
    type: string
    sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  }

  dimension: sales_user {
    type: number
    sql: ${TABLE}."SALES_USER" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: total_points {
    type: number
    sql: ${TABLE}."TOTAL_POINTS" ;;
  }

  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, company_name]
  }
}
