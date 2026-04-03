SELECT
    o.organization_id,
    o.company_id,
    o.name,
    o._es_update_timestamp
FROM {{ source('es_warehouse_public', 'organizations') }} as o
