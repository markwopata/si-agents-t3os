view: collector_mktassignments {
  sql_table_name: "PUBLIC"."COLLECTOR_MKTASSIGNMENTS"
    ;;

  dimension: collector {
    type: string
    sql: ${TABLE}."Collector" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region_id {
    type: string
    sql: ${TABLE}."REGION_ID" ;;
  }

  dimension: u_id {
    type: string
    sql: ${TABLE}."U_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
