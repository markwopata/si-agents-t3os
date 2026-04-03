SELECT
    au.asset_usage_id,
    au.asset_id,
    au.miles_driven,
    au.on_time,
    au.report_date,
    au.hauled_time,
    au.hauled_distance,
    au.hauling_time,
    au.hauling_distance,
    au.idle_time,
    au._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_usage') }} as au
