SELECT
    tm.tracker_device_serial,
    tm.tracker_vendor,
    tm.asset_id,
    tm.asset_name,
    tm.company_id,
    tm.asset_type,
    tm.keypad_controller_type_id,
    tm.tracker_tracker_id,
    tm.esdb_tracker_id,
    tm.tracker_grouping
FROM {{ source('es_warehouse_public', 'trackers_mapping') }} as tm
