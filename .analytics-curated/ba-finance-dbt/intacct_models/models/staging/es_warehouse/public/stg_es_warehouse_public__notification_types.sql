SELECT
    nt.notification_type_id,
    nt.name,
    nt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'notification_types') }} as nt
