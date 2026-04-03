view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK" ;;

  dimension: _id_dist {
    type: number
    value_format_name: id
    sql: ${TABLE}."_ID_DIST" ;;
  }
  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }
  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }

  dimension: branch_earnings_start {
    type: date_raw
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
    hidden:  yes
  }

  dimension: date_updated {
    type: date_raw
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: market_id {
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
  dimension: market_type_id {
    type: number
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }
}
