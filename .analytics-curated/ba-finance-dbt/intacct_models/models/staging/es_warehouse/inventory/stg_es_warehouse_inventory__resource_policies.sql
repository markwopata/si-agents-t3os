SELECT
    rp.resource_policy_id,
    rp.group_id,
    rp.resource_id,
    rp.role_id,
    rp.date_created,
    rp.date_updated,
    rp._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'resource_policies') }} as rp
