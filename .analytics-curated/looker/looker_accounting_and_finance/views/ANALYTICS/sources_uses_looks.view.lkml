view: sources_uses_looks {
  sql_table_name: "ANALYTICS"."TREASURY"."SOURCES_USES_LOOKS" ;;



  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: source_use {
    type: string
    sql: ${TABLE}."SOURCE_USE" ;;
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  measure: amount {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }


}
