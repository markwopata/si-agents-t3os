view: maintenance_and_repair {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."INT_BRANCH_EARNINGS_MAINTENANCE_REPAIR" ;;

  dimension: market_id {
    label: "Market ID"
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: month_start {
    label: "Month Start"
    type: date
    sql: ${TABLE}."MONTH_START" ;;
  }

  dimension: account_number {
    label: "Account Number"
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    label: "Account Name"
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: amount {
    label: "Amount"
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."AMOUNT" ;;

  }

  measure: sum_of_amount {
    label: "Sum of Amount"
    type: sum
    sql: ${amount} ;;
    value_format: "#,##0.00;(#,##0.00);-"
    link: {
      label: "Detail View"
      url: "@{lk_be_bucket_detail}?f[market_region_xwalk.market_name]={{ maintenance_and_repair.market_name | prepend: '%22' | append: '%22' }}&f[plexi_periods.display]={{ maintenance_and_repair.month_start | date: '%B %Y' | url_encode }}&f[be_transaction_listing.gl_acctno]={{ maintenance_and_repair.account_number | url_encode }}&f[be_transaction_listing.gl_acct]={{ maintenance_and_repair.account_name | url_encode }}&toggle=det"
    }
  }



  dimension: source {
    label: "Source"
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: month_label {
    label: "Month"
    type: string
    sql: TO_CHAR(${TABLE}."MONTH_START", 'Mon YYYY') ;;
    order_by_field: month_start
  }

}
