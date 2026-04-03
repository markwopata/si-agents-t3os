SELECT
    ti.time_interval_id,
    ti.unit_id,
    ti.value,
    ti.date_created,
    ti.date_updated,
    ti._es_update_timestamp
FROM {{ source('es_warehouse_public', 'time_intervals') }} as ti
