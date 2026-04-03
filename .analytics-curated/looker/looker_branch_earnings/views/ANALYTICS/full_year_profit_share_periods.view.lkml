view: full_year_profit_share_periods {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."FULL_YEAR_PROFIT_SHARE_PERIODS" ;;

  dimension: display {
    type: string
    sql: ${TABLE}."DISPLAY" ;;
  }
  dimension: period_published {
    type: string
    sql: ${TABLE}."PERIOD_PUBLISHED" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
}
