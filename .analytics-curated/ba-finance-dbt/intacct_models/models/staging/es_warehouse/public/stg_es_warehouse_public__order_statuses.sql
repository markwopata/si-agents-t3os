SELECT
    os.order_status_id,
    os.name,
    os._es_update_timestamp
FROM {{ source('es_warehouse_public', 'order_statuses') }} as os
