view: asset_ownership {
  sql_table_name: "ANALYTICS"."BI_OPS"."ASSET_OWNERSHIP";;

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_company_id {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension: asset_company_owner {
    type: string
    sql: ${TABLE}."ASSET_COMPANY_OWNER" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rentable {
    type: string
    sql: ${TABLE}."RENTABLE" ;;
  }

  dimension: market_company_id {
    type: string
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }

  dimension: market_company_name {
    type: string
    sql: ${TABLE}."MARKET_COMPANY_NAME" ;;
  }

  dimension: ownership {
    type: string
    sql: ${TABLE}."OWNERSHIP" ;;
  }
}
