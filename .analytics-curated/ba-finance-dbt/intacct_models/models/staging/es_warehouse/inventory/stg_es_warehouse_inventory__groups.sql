SELECT
    g.group_id,
    g.name,
    g.company_id,
    g.spending_limit,
    g.date_created,
    g.date_updated,
    g.date_archived,
    g._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'groups') }} as g
