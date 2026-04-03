view: sources_temporary {
  sql_table_name: "ANALYTICS"."TREASURY"."SOURCES_TEMPORARY"
    ;;

  measure: amount {
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
