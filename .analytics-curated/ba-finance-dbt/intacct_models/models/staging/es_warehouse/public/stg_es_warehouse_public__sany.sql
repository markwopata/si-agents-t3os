SELECT
    s.device_serial,
    s.tracker_type_id,
    s.tracker_id,
    s.asset_id
FROM {{ source('es_warehouse_public', 'sany') }} as s
