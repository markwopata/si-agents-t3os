SELECT
    rt.resource_type_id,
    rt.name,
    rt._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'resource_types') }} as rt
