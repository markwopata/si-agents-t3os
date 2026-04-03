SELECT
    assa.asset_sensor_statuses_audit_id,
    assa.asset_sensor_status_id,
    assa.asset_id,
    assa.asset_sensor_id,
    assa.value,
    assa.value_timestamp,
    assa.tracking_event_id,
    assa.date_created,
    assa.date_updated,
    assa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_sensor_statuses_audit') }} as assa
