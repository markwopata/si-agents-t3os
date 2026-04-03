SELECT
    dp.delivery_photo_id,
    dp.delivery_id,
    dp.photo_id,
    dp._es_update_timestamp
FROM {{ source('es_warehouse_public', 'delivery_photos') }} as dp
