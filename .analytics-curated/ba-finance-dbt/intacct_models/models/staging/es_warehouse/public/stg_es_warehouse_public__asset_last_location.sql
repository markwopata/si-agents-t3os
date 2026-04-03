SELECT
    allo.asset_id,
    allo.geofences,
    allo.address,
    allo.location,
    allo.last_location_timestamp,
    allo.last_checkin_timestamp
FROM {{ source('es_warehouse_public', 'asset_last_location') }} as allo
