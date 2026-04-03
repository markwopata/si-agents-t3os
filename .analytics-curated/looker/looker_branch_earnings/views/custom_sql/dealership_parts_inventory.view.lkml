view: dealership_parts_inventory {
  derived_table: {
    sql:
    with parts_attributes as(
select distinct part_id, part_categorization_id
            from analytics.parts_inventory.parts_attributes
            where end_date::date = '2999-01-01' and part_categorization_id is not null)

select rm.retail_territory
     , m.region_name as region
     , m.district
     , m.market_id
     , m.market_name
     , sp.part_id
     , p.part_number
     , sp.quantity
     , sp.available_quantity
     , sp.quantity * acs.weighted_average_cost as dollar_value
     , pa.part_categorization_id
     , pcs.category
     , pcs.subcategory
     , pro.name as brand
 from es_warehouse.inventory.store_parts sp
 left join es_warehouse.inventory.weighted_average_cost_snapshots acs
    on sp.part_id = acs.product_id
        and sp.inventory_location_id = acs.inventory_location_id
        and acs.is_current = true
 left join es_warehouse.inventory.parts p on sp.part_id = p.part_id
 left join es_warehouse.inventory.providers pro on p.provider_id = pro.provider_id
 left join parts_attributes pa on sp.part_id = pa.part_id
 left join analytics.parts_inventory.part_categorization_structure pcs on pa.part_categorization_id = pcs.part_categorization_id
 join analytics.branch_earnings.market m on sp.inventory_location_id = m.child_market_id
 join analytics.dbt_seeds.seed_retail_market_map rm on m.child_market_id = rm.market_id
 where sp.quantity <> 0
      ;;
  }

  dimension: retail_territory {
    type: string
    sql: ${TABLE}."RETAIL_TERRITORY" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "MarketID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: part_id {
    label: "PartID"
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  measure: quantity {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: ${TABLE}."QUANTITY" ;;
  }

  measure: available_quantity {
    type: sum
    value_format_name: decimal_0
    drill_fields: [drill_fields*]
    sql: ${TABLE}."AVAILABLE_QUANTITY" ;;
  }

  measure: dollar_value {
    type: sum
    value_format_name: decimal_2
    drill_fields: [drill_fields*]
    sql: ${TABLE}."DOLLAR_VALUE" ;;
  }

  dimension: part_categorization_id {
    type: string
    sql: ${TABLE}."PART_CATEGORIZATION_ID" ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}."SUBCATEGORY" ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}."BRAND" ;;
  }

  set: drill_fields {
    fields: [
      retail_territory,
      market,
      part_id,
      part_number,
      category,
      subcategory,
      brand,
      quantity,
      dollar_value
    ]
  }

}
