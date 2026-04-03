view: sources_uses_manual {
  sql_table_name: "ANALYTICS"."TREASURY"."SOURCES_USES_MANUAL"
    ;;

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: desc {
    type: string
    sql: ${TABLE}."DESC" ;;
  }

  dimension: source_use {
    type: string
    sql: ${TABLE}."SOURCE_USE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
