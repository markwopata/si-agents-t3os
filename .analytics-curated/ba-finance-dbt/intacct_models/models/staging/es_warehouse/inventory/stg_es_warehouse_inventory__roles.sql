SELECT
    r.role_id,
    r.name,
    r.company_id,
    r.spending_limit,
    r.date_created,
    r.date_updated,
    r.date_archived,
    r._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'roles') }} as r
