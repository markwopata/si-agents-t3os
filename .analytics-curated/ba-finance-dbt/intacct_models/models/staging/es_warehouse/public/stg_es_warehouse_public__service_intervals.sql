SELECT
    si.service_interval_id,
    si.time_interval_id,
    si.usage_interval_id,
    si.name,
    si.date_created,
    si.date_updated,
    si._es_update_timestamp
FROM {{ source('es_warehouse_public', 'service_intervals') }} as si
