SELECT
    ase.asset_sensor_id,
    ase.asset_id,
    ase.tracker_id,
    ase.asset_sensor_type_id,
    ase.label,
    ase.date_created,
    ase._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_sensors') }} as ase
