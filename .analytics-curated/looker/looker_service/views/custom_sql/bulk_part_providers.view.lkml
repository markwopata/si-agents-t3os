view: bulk_part_providers {
  derived_table: {
    sql:
    select distinct pro.name                                manufacturer,
                    coalesce(p2.part_number, p.part_number) part_number,
                    pt.description,
                    pc.NAME                                 part_category,
                    coalesce(p2.part_id, p.part_id)         part_id
    from ES_WAREHOUSE.INVENTORY.PARTS p
             left join es_warehouse.inventory.parts p2
                       on p.DUPLICATE_OF_ID = p2.PART_ID
             join es_warehouse.INVENTORY.PART_TYPES pt
                  on coalesce(p2.part_type_id, p.PART_TYPE_ID) = pt.PART_TYPE_ID
             left join ES_WAREHOUSE.INVENTORY.PART_CATEGORIES pc
                       on pt.PART_CATEGORY_ID = pc.PART_CATEGORY_ID
             join ES_WAREHOUSE.INVENTORY.PROVIDERS pro
                  on coalesce(p2.provider_id, p.PROVIDER_ID) = pro.PROVIDER_ID
    where pro.name like 'BULK - %'
      and p.COMPANY_ID in (1854, 1855, 8151, 61036)
      and p.DATE_ARCHIVED is null
      ;;
  }

  dimension: manufacturer {
    type: string
    sql: ${TABLE}.manufacturer ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: part_category {
    type: string
    sql: ${TABLE}.part_category ;;
  }

  dimension: part_id {
    type: string
    value_format_name: id
    sql: ${TABLE}.part_id ;;
  }
}
