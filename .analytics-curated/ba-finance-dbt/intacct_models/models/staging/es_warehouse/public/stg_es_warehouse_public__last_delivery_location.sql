SELECT
    ldl.asset_id,
    ldl.rental_id,
    ldl.delivery_id,
    ldl.drop_off_or_return,
    ldl.address,
    ldl.last_delivery
FROM {{ source('es_warehouse_public', 'last_delivery_location') }} as ldl
