view: dealership_market_map {
  derived_table: {
    sql:
    select distinct
       rm.retail_territory
     , m.region_name
     , m.district
     , m.market_id
     , m.market_name
     , rm.is_retail_rental_hybrid
 from analytics.dbt_seeds.seed_retail_market_map rm
 join analytics.branch_earnings.market m on rm.market_id = m.child_market_id;;
  }

  dimension: retail_territory {
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: region_name {
    label: "Region"
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    label: "Market"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

}
