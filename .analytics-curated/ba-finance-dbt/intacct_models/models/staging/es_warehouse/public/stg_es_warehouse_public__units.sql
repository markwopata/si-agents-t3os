SELECT
    u.unit_id,
    u.unit_type_id,
    u.unit_system_id,
    u.name,
    u.abbreviation,
    u.date_created,
    u.date_updated,
    u._es_update_timestamp
FROM {{ source('es_warehouse_public', 'units') }} as u
