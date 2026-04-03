SELECT
    hagu.hourly_asset_geofence_usage_id,
    hagu.geofence_id,
    hagu.hours,
    hagu.report_range,
    hagu.asset_id,
    hagu._es_update_timestamp,
    hagu.report_range:"end_bound" AS report_range__end_bound,
    hagu.report_range:"start_bound" AS report_range__start_bound,
    hagu.report_range:"end_range" AS report_range__end_range,
    hagu.report_range:"start_range" AS report_range__start_range
FROM {{ source('es_warehouse_public', 'hourly_asset_geofence_usage') }} as hagu
