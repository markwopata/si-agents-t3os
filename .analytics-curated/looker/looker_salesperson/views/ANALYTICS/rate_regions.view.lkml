view: rate_regions {
  derived_table: {
  sql:
  select
  r.market_name as standard_branch,
  rr.district as district,
  rr.market_id as market_id,
  rr.market_name as market_name,
  rr.region as region,
  rr.region_name as region_name,
  rr.standard_branch_id as standard_branch_id
  from analytics.rate_achievement.rate_regions as rr
  left join analytics.rate_achievement.rate_regions as r
  on rr.standard_branch_id = r.market_id


  ;;
}
  dimension: _id_dist {
    type: number
    value_format_name: id
    sql: ${TABLE}."_ID_DIST" ;;
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
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: standard_branch_id {

    type: number
    sql: ${TABLE}."STANDARD_BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: standard_branch {

    type: string
    sql: ${TABLE}."STANDARD_BRANCH" ;;

  }
  measure: count {
    type: count
    drill_fields: [market_name, region_name]
  }
}
