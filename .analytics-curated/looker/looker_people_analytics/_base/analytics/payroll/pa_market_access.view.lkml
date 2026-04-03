view: pa_market_access {
  sql_table_name: "ANALYTICS"."PAYROLL"."PA_MARKET_ACCESS" ;;

  dimension: market_access_emails {
    type: string
    sql: ${TABLE}."MARKET_ACCESS_EMAILS" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  measure: count {
    type: count
  }
}
