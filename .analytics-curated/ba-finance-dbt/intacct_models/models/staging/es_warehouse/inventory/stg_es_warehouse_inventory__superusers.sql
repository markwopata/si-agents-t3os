SELECT
    s.superuser_id,
    s.user_id,
    s._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'superusers') }} as s
