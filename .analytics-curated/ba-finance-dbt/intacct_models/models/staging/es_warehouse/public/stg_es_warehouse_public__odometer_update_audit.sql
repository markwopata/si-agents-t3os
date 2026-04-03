SELECT
    oua.odometer_update_audit_id,
    oua.asset_id,
    oua.trip_distance_accumulator,
    oua.created,
    oua.tracking_event_id,
    oua.user_id,
    oua.application_name,
    oua.new_odometer,
    oua.odometer_accumulator,
    oua.old_odometer,
    oua._es_update_timestamp
FROM {{ source('es_warehouse_public', 'odometer_update_audit') }} as oua
