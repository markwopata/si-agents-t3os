SELECT
    r.region_id,
    r.name,
    r.company_id,
    r.date_created,
    r.date_updated,
    r._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'regions') }} as r
