view: ar_weekly_dso {
  sql_table_name: "PUBLIC"."AR_WEEKLY_DSO"
    ;;

  dimension: avg_dso {
    type: number
    sql: ${TABLE}."AVG_DSO" ;;
  }

  dimension: date_week {
    type: string
    sql: ${TABLE}."DATE_WEEK" ;;
  }

  dimension: market_dso {
    type: number
    sql: ${TABLE}."MARKET_DSO" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: revenue {
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: tot_outstanding {
    type: number
    sql: ${TABLE}."TOT_OUTSTANDING" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
