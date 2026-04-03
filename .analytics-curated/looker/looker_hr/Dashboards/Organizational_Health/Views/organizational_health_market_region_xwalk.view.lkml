view: market_region_xwalk {
  sql_table_name: "PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: is_dealership {
    type: string
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }


  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }


  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }

  measure: count_distinct_market_id {
    type: count_distinct
    sql:  ${TABLE}."MARKET_ID" ;;
  }
}
