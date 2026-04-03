view: t3_revenue_support {

  derived_table: {
    sql: select *
from ANALYTICS.ACCOUNTING.T3_REVENUE_SUPPORT
order by REPORT_START_DATE, MARKET_ID
      ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}.market_id ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }
  dimension: billed {
    type: number
    sql: ${TABLE}.billed ;;
  }
  dimension: unbilled {
    type: number
    sql: ${TABLE}.unbilled ;;
  }
  dimension: report_start_date {
    type: date
    sql: ${TABLE}.report_start_date ;;
  }
  dimension: report_end_date {
    type: date
    sql: ${TABLE}.report_end_date ;;
  }
}
