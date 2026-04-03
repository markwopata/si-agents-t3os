SELECT
    tlm.asset_id,
    tlm.trip_id,
    tlm.start_timestamp,
    tlm.end_timestamp
FROM {{ source('es_warehouse_public', 'trips_last_month') }} as tlm
