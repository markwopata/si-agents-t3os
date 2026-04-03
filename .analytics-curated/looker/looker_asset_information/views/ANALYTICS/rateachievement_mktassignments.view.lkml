view: rateachievement_mktassignments {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_MKTASSIGNMENTS"
    ;;

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rate_region {
    type: string
    sql: ${TABLE}."RATE_REGION" ;;
  }

  dimension: region_index {
    type: number
    sql: ${TABLE}."REGION_INDEX" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
