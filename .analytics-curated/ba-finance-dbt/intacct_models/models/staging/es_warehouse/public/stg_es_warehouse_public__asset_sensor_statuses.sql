SELECT
    ass.asset_sensor_status_id,
    ass.asset_id,
    ass.asset_sensor_id,
    ass.value,
    ass.value_timestamp,
    ass.tracking_event_id,
    ass.asset_sensor_health_type_id,
    ass.date_created,
    ass.date_updated,
    ass._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_sensor_statuses') }} as ass
