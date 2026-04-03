{{
    config(materialized='table',)
}}
with recursive part_hierarchy as (
    select
        1 as level, -- Keep track of hierarchy level
        p.part_id,
        p.duplicate_of_id,
        p.part_id as root_part_id -- Keep track of the root part_id
    from {{ ref("stg_es_warehouse_inventory__parts") }} as p
    where p.duplicate_of_id is null -- Get the origin parts

    union all

    select
        ph.level + 1 as level,
        p.part_id,
        p.duplicate_of_id,
        ph.root_part_id
    from part_hierarchy as ph
        inner join {{ ref("stg_es_warehouse_inventory__parts") }} as p
            on ph.part_id = p.duplicate_of_id
-- Recursion keeps going until there's a null duplicate_of_id
-- union all recursively adds to the pool of top level part_ids when there's a part_id = duplicate_of_id match
)

select
    p.part_id,
    p.part_type_id,
    p.provider_part_number_id,
    p.company_id,
    p.date_archived,
    p.duplicate_of_id,
    p.part_number,
    -- Part type description = part.name for all but 1 part.
    p.description,
    ph.root_part_id,
    ph.level,
    p2.part_number as root_part_number,
    p2.description as root_part_description,
    p.provider_id,
    p.verified,
    p.sku_field,
    p.verified_for_company,
    p.verified_globally,
    p.item_id,
    p.upc,
    p.msrp,
    p.search,
    p.is_global,
    p.year,
    p.product_type_id,
    p.manufacturer_id,
    p.manufacturer_number,
    p.manufacturer_family_id,
    p.model,
    p.product_category_id,
    p.product_class_id,
    p.conversion_unit_id,
    p.date_created,
    p.date_updated,
    p._es_update_timestamp
from part_hierarchy as ph
    inner join {{ ref("stg_es_warehouse_inventory__parts") }} as p
        on ph.part_id = p.part_id
    inner join {{ ref("stg_es_warehouse_inventory__parts") }} as p2
        on ph.root_part_id = p2.part_id
