SELECT
    agu.geofence_id,
    agu.date,
    agu.asset_geofence_usage_id,
    agu.asset_id,
    agu.hours,
    agu._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_geofence_usage') }} as agu
