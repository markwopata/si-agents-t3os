SELECT
    dt.delivery_type_id,
    dt.name,
    dt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'delivery_types') }} as dt
