view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: district_text {
    type: string
    sql: ${TABLE}."DISTRICT" ::text ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ::text ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: dealership_y_n {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
}
