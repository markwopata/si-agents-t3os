view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
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

  dimension: district_region_market_access {
    type: yesno
    sql: ${district} in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id} in ({{ _user_attributes['market_id'] }}) ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }
}
