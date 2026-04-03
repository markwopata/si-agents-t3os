SELECT
    lav.location_id,
    lav.address
FROM {{ source('es_warehouse_public', 'location_address_vw') }} as lav
