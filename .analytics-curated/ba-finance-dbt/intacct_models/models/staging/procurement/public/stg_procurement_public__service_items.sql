SELECT
    si.service_item_id,
    si.name,
    si.item_id,
    si._es_update_timestamp
FROM {{ source('procurement_public', 'service_items') }} as si
