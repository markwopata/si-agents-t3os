view: int_live_branch_earnings_revenue_estimate {
  sql_table_name: "BRANCH_EARNINGS"."INT_LIVE_BRANCH_EARNINGS_REVENUE_ESTIMATE" ;;

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
    value_format_name: usd_0
  }
  measure: count {
    type: count
  }
}
