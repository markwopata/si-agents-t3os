view: ukg_cost_center_market_id_mapping {
  sql_table_name: "ANALYTICS"."PAYROLL"."UKG_COST_CENTER_MARKET_ID_MAPPING"
    ;;

  dimension: _cost_centers_full_path {
    type: string
    sql: ${TABLE}."_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: intaact_code {
    type: string
    sql: ${TABLE}."INTAACT_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
