view: market_goals {
  sql_table_name: "ANALYTICS"."GS"."MARKET_GOALS" ;;

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
    primary_key: yes
  }
  dimension: market_level {
    type: string
    sql: ${TABLE}."MARKET_LEVEL" ;;
  }
  dimension: months {
    type: string
    sql: ${TABLE}."MONTHS" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: revenue_goals {
    type: string
    sql: ${TABLE}."REVENUE_GOALS" ;;
  }
  dimension: start_date {
    type: string
    sql: ${TABLE}."START_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [name]
  }
}
