view: market_region_xwalk {
  sql_table_name: "ANALYTICS"."PUBLIC"."MARKET_REGION_XWALK"
    ;;

  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
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

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT"::text ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: District_Region_Market_Access {
    type: yesno
    sql: ${district}::text in ({{ _user_attributes['district'] }}) OR ${region_name} in ({{ _user_attributes['region'] }}) OR ${market_id}::text in ({{ _user_attributes['market_id'] }}) ;;
  }

  # ----- Set Fields for Drilling -----
  set: detail {
    fields: [
      market_id,
      market_name,
      region,
      state
    ]
  }
}
