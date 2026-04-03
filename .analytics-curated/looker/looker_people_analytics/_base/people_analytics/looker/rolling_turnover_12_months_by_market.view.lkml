view: rolling_turnover_12_months_by_market {
  sql_table_name: "LOOKER"."ROLLING_TURNOVER_12_MONTHS_BY_MARKET" ;;

  dimension: avg_headcount_12_mo {
    type: number
    sql: ${TABLE}."AVG_HEADCOUNT_12MO" ;;
  }
  dimension: date_month {
    type: date_raw
    sql: ${TABLE}."DATE_MONTH" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: non_regrettable_12_mo {
    type: number
    sql: ${TABLE}."NON_REGRETTABLE_12MO" ;;
  }
  dimension: regrettable_12_mo {
    type: number
    sql: ${TABLE}."REGRETTABLE_12MO" ;;
  }
  dimension: terminations_12_mo {
    type: number
    sql: ${TABLE}."TERMINATIONS_12MO" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
