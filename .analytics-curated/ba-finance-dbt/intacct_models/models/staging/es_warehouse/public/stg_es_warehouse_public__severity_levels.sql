SELECT
    sl.severity_level_id,
    sl.name,
    sl._es_update_timestamp
FROM {{ source('es_warehouse_public', 'severity_levels') }} as sl
