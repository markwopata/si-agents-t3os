view: quarterly_profit_share_periods {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."QUARTERLY_PROFIT_SHARE_PERIODS" ;;

  dimension: display {
    type: string
    sql: ${TABLE}."DISPLAY" ;;
    primary_key: yes
  }
  dimension: period_published {
    type: string
    sql: ${TABLE}."PERIOD_PUBLISHED" ;;
  }
  dimension: qtr_num {
    type: number
    sql: ${TABLE}."QTR_NUM" ;;
  }
  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }
  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }
  measure: count {
    type: count
  }
}
