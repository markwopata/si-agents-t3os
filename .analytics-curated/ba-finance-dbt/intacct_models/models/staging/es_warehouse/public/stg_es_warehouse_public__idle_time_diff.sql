SELECT
    itd.id
FROM {{ source('es_warehouse_public', 'idle_time_diff') }} as itd
