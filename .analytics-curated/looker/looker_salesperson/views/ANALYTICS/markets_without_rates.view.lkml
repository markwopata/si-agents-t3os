view: markets_without_rates {
  sql_table_name: "PUBLIC"."MARKETS_WITHOUT_RATES"
    ;;

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rev {
    type: number
    sql: ${TABLE}."REV" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
