SELECT
    s.store_id,
    s.company_id,
    s.store_type_id,
    s.parent_id,
    s.name,
    s.branch_id,
    s.inventory_type_id,
    s.date_created,
    s.date_updated,
    s.date_archived,
    s._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'stores') }} as s
