SELECT
    cc.consumable_category_id,
    cc.name,
    cc.parent_category_id,
    cc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'consumable_categories') }} as cc
