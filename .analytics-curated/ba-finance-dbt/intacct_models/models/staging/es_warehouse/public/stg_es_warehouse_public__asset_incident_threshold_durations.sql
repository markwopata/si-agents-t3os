SELECT
    aitd.asset_incident_threshold_duration_id,
    aitd.asset_id,
    aitd.tracker_id,
    aitd.asset_incident_threshold_id,
    aitd.start_timestamp,
    aitd.end_timestamp,
    aitd.duration_seconds,
    aitd.start_incident_id,
    aitd.end_incident_id,
    aitd.cleared_threshold_value,
    aitd.exceeded_threshold_value,
    aitd.extreme_threshold_value,
    aitd.baseline_threshold_value,
    aitd.date_created,
    aitd._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_incident_threshold_durations') }} as aitd
