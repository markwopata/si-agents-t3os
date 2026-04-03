SELECT
    ds.delivery_status_id,
    ds.name,
    ds._es_update_timestamp
FROM {{ source('es_warehouse_public', 'delivery_statuses') }} as ds
