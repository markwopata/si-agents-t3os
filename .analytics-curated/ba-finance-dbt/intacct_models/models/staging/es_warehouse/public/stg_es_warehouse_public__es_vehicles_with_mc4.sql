SELECT
    evwm.device_serial,
    evwm.tracker_type_id,
    evwm.tracker_id,
    evwm.asset_id,
    evwm.make,
    evwm.model,
    evwm.year
FROM {{ source('es_warehouse_public', 'es_vehicles_with_mc4') }} as evwm
