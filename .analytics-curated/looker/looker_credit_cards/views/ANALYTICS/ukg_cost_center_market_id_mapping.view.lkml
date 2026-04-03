view: ukg_cost_center_market_id_mapping {
  sql_table_name: "PAYROLL"."UKG_COST_CENTER_MARKET_ID_MAPPING"
    ;;

  dimension: cost_centers_full_path {
    type: string
    sql: ${TABLE}."_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."INTAACT_CODE";;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
