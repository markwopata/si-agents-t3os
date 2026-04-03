SELECT
    uttl.unhealthy_tracker_trait_log_id,
    uttl.asset_id,
    uttl.optional_fields,
    uttl.date_ended,
    uttl.unhealthy_tracker_log_id,
    uttl.date_started,
    uttl.unhealthy_tracker_trait_type_id,
    uttl.tracker_id,
    uttl.debounced_tracking_event_ids,
    uttl.date_created,
    uttl._es_update_timestamp,
    uttl.optional_fields:"end_incident_id" AS optional_fields__end_incident_id,
    uttl.optional_fields:"start_staleness_seconds" AS optional_fields__start_staleness_seconds,
    uttl.optional_fields:"stale_threshold_seconds" AS optional_fields__stale_threshold_seconds,
    uttl.optional_fields:"duration_seconds" AS optional_fields__duration_seconds,
    uttl.optional_fields:"start_gps_fix_timestamp" AS optional_fields__start_gps_fix_timestamp,
    uttl.optional_fields:"start_incident_id" AS optional_fields__start_incident_id
FROM {{ source('es_warehouse_public', 'unhealthy_tracker_trait_logs') }} as uttl
