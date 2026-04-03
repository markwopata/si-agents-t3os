view: pa_market_access {
  sql_table_name: "ANALYTICS"."PAYROLL"."PA_MARKET_ACCESS" ;;

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
}
  dimension: market_access_email {
    type: string
    sql: ${TABLE}."MARKET_ACCESS_EMAILS" ;;
  }
}
