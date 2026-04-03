view: outstanding_balances {
  sql_table_name: "CLIO_GOLD"."OUTSTANDING_BALANCES" ;;

  dimension: bill_id {
    type: string
    sql: ${TABLE}."BILL_ID" ;;
  }
  dimension_group: extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EXTRACTED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: matter_id {
    type: string
    sql: ${TABLE}."MATTER_ID" ;;
  }
  dimension: total_outstanding_balance {
    type: number
    sql: ${TABLE}."TOTAL_OUTSTANDING_BALANCE" ;;
  }
  measure: count {
    type: count
  }
}
