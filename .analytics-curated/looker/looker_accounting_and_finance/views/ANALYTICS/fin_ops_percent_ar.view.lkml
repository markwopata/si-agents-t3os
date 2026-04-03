view: fin_ops_percent_ar {
  sql_table_name: "ANALYTICS"."TREASURY"."FIN_OPS_PERCENT_AR" ;;

 ########## DIMENSIONS ##########

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  dimension: ar_status {
    label: "A/R Status"
    type: string
    sql: ${TABLE}."AR_STATUS" ;;
  }

  ########## MEASURES ##########

  measure: percent_ar {
    label: "Percent of A/R"
    value_format_name: percent_0
    type: sum
    sql: ${TABLE}."PERCENT_AR" ;;
  }


}
