SELECT
    d.domain_id,
    d.name
FROM {{ source('es_warehouse_public', 'domains') }} as d
