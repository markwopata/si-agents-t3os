SELECT
    ase.asset_settings_id,
    ase.idling,
    ase.ifta_reporting,
    ase.alert_enter_geofence,
    ase.alert_exit_geofence,
    ase.alert_time_fence,
    ase.entering_geofence,
    ase.leaving_geofence,
    ase._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_settings') }} as ase
