SELECT
    c.consumable_id,
    c.company_id,
    c.consumable_category_id,
    c.name,
    c._es_update_timestamp
FROM {{ source('es_warehouse_public', 'consumables') }} as c
