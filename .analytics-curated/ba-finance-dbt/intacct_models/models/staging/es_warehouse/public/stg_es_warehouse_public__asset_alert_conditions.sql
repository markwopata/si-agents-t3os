SELECT
    aac._es_load_timestamp,
    aac.asset_alert_condition_id,
    aac.on_exit_geofence,
    aac.date_deactivated,
    aac.asset_incident_threshold_id,
    aac.asset_alert_condition_type_id,
    aac.timefence_id,
    aac.geofence_id,
    aac.tracking_incident_type_id,
    aac.on_enter_geofence,
    aac.asset_alert_rule_id,
    aac.date_created,
    aac._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_conditions') }} as aac
