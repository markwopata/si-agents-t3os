SELECT
    rp.role_permission_id,
    rp.role_id,
    rp.permission_id,
    rp.date_created,
    rp.date_updated,
    rp._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'role_permissions') }} as rp
