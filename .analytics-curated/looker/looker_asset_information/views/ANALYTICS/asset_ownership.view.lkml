view: asset_ownership {
  sql_table_name: "BI_OPS"."ASSET_OWNERSHIP" ;;

  dimension: asset_company_id {
    type: number
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }
  dimension: asset_company_owner {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_OWNER" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }
  dimension: market_company_name {
    type: string
    sql: ${TABLE}."MARKET_COMPANY_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
  dimension: rentable {
    type: yesno
    sql: ${TABLE}."RENTABLE" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_company_name, market_name]
  }
  measure: count_non_rentable {
    type: count_distinct
    sql: CASE WHEN ${rentable} = FALSE then ${asset_id} ELSE NULL END ;;
  }
}
