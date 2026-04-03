SELECT
    r.resource_id,
    r.parent_id,
    r.object_id,
    r.company_id,
    r.resource_type_id,
    r.date_created,
    r.date_updated,
    r._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'resources') }} as r
