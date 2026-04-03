SELECT
    rt.rate_type_id,
    rt.name,
    rt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rate_types') }} as rt
