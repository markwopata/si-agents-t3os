view: fin_ops_collections_ttm_revenue {
  sql_table_name: "ANALYTICS"."TREASURY"."FIN_OPS_COLLECTIONS_TTM_REVENUE" ;;

########## DIMENSIONS ##########

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  ########## MEASURES ##########

  measure: collections {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS" ;;
  }

  measure: collections_mm {
    label: "Collections"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."COLLECTIONS"/1000000 ;;
  }

  measure: collections_pct_ttm_revenue {
    label: "Collections Percent of TTM Revenue"
    value_format_name: percent_0
    type: sum
    sql: ${TABLE}."COLLECTIONS_PCT_TTM_REVENUE" ;;
  }

  measure: ttm_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TTM_REVENUE" ;;
  }

  measure: total_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: current_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."CURRENT_AR" ;;
  }

  measure: past_due_ar {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."PAST_DUE_AR" ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: collections_pct_quarterly_revenue {
    value_format_name: percent_0
    type: number
    sql: ${collections}/${revenue} ;;
  }





}
