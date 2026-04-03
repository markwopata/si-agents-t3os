SELECT
    p.permission_id,
    p.name,
    p.friendly_name,
    p.resource_type_id,
    p._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'permissions') }} as p
