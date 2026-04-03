SELECT
    pc.part_category_id,
    pc.name,
    pc.description,
    pc.company_id,
    pc.parent_id,
    pc.category_number,
    pc.sku_field,
    pc.date_created,
    pc.date_updated,
    pc._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'part_categories') }} as pc
