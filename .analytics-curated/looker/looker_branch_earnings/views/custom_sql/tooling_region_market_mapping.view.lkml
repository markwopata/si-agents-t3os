view: tooling_region_market_mapping {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."TOOLING_REGION_MARKET_MAPPING" ;;

  dimension: manager_id {
    type: number
    sql: ${TABLE}."MANAGER_ID" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_manager_name {
    type: string
    sql: ${TABLE}."MARKET_MANAGER_NAME" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, market_manager_name]
  }
}
