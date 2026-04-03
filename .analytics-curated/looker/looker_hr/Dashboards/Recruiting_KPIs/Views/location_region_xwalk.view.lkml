view: location_region_xwalk {
  sql_table_name: "GREENHOUSE"."LOCATION_REGION_XWALK"
    ;;

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: district{
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }


  measure: count {
    type: count
    drill_fields: []
  }
}
