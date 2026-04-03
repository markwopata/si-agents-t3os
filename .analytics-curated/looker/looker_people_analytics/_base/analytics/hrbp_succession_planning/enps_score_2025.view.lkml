view: enps_score_2025 {
  sql_table_name: "ANALYTICS"."ANALYTICS"."ENPS_SCORE_2025" ;;

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: gm_ee_id {
    type: number
    sql: ${TABLE}."GM_EE_ID" ;;
  }
  dimension: gm_name {
    type: string
    sql: ${TABLE}."GM_NAME" ;;
  }
  dimension: enps {
    type: number
    sql: ${TABLE}."ENPS" ;;
  }



}
