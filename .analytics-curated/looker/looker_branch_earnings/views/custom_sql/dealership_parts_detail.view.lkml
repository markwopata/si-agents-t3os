view: dealership_parts_detail {
  derived_table: {
    sql:
    with parts_attributes as(
select distinct part_id, part_categorization_id
            from analytics.parts_inventory.parts_attributes
            where end_date::date = '2999-01-01' and part_categorization_id is not null)

select p.part_id
     , p.part_number
     , pcs.category
     , pcs.subcategory
     , pro.name as brand
 from es_warehouse.inventory.parts p
 left join parts_attributes pa on p.part_id = pa.part_id
 left join analytics.parts_inventory.part_categorization_structure pcs on pa.part_categorization_id = pcs.part_categorization_id
 left join es_warehouse.inventory.providers pro on p.provider_id = pro.provider_id
      ;;
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

}
