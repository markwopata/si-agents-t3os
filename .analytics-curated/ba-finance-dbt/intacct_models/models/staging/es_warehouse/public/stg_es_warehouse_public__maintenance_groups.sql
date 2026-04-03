SELECT
    mg.maintenance_group_id,
    mg.name,
    mg.description,
    mg.company_id,
    mg.archived_date,
    mg.date_created,
    mg.date_updated,
    mg._es_update_timestamp
FROM {{ source('es_warehouse_public', 'maintenance_groups') }} as mg
