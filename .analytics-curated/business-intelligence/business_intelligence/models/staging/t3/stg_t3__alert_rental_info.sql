{{ config(
    materialized='table'
) }}

SELECT
    ndl.notification_delivery_log_id,
    COALESCE(ti.asset_id, tdc.asset_id) AS asset_id,
    COALESCE(ti.report_timestamp, tdc.report_timestamp) AS report_timestamp,

    CASE
        -- WHEN aitd.asset_incident_threshold_duration_id IS NOT NULL
        --      AND aitd.end_timestamp IS NULL THEN 'ACTIVE'
        -- WHEN aitd.end_timestamp IS NOT NULL THEN 'CLEARED'
        -- ELSE NULL 
         WHEN aitd.asset_incident_threshold_duration_id IS NOT NULL
             AND aitd.end_timestamp IS NULL THEN 'ACTIVE INCIDENT'
        WHEN aitd.end_timestamp IS NOT NULL THEN 'CLEARED INCIDENT'
        WHEN aitd.asset_incident_threshold_duration_id IS NULL THEN 'NON-INCIDENT ALERT'
    END AS current_status,

    CASE
        -- WHEN u.company_id IS NULL AND a.company_id IS NULL THEN 'UKNOWN'
        -- WHEN ea.rental_id IS NOT NULL THEN 'RENTED'
        -- WHEN u.company_id = a.company_id THEN 'OWNED'
        -- ELSE 'UNKNOWN'
        WHEN a.asset_id IS NULL THEN 'NON-ASSET ALERT'
        WHEN u.company_id = a.company_id THEN 'OWNED'
        WHEN u.company_id != a.company_id THEN 'RENTED'
    END AS asset_ownership,

    ea.rental_id,
    rsi.ordered_by,
    l.nickname AS jobsite,
    CONCAT(l.street_1, ', ', l.city, ', ', s.name, ', ', l.zip_code) AS jobsite_address

FROM es_warehouse.public.notification_delivery_logs ndl
LEFT JOIN es_warehouse.public.users u USING (user_id)
LEFT JOIN es_warehouse.public.tracking_incidents ti USING (tracking_incident_id)
LEFT JOIN es_warehouse.public.tracking_diagnostic_codes tdc USING (tracking_diagnostic_codes_id)
LEFT JOIN es_warehouse.public.asset_incident_threshold_durations aitd ON aitd.start_incident_id = COALESCE(ndl.tracking_incident_id, ti.tracking_incident_id)
LEFT JOIN es_warehouse.public.assets a ON COALESCE(ti.asset_id, tdc.asset_id) = a.asset_id
LEFT JOIN es_warehouse.public.equipment_assignments ea
    ON ea.asset_id = COALESCE(ti.asset_id, tdc.asset_id)
    AND COALESCE(ti.report_timestamp, tdc.report_timestamp) >= ea.start_date
    AND (ea.end_date IS NULL OR COALESCE(ti.report_timestamp, tdc.report_timestamp) <= ea.end_date)
LEFT JOIN business_intelligence.triage.stg_t3__rental_status_info rsi
    ON rsi.rental_id = ea.rental_id
    -- AND rsi.company_id = u.company_id
LEFT JOIN es_warehouse.public.rental_location_assignments rla
    ON rla.rental_id = ea.rental_id
    AND COALESCE(ti.report_timestamp, tdc.report_timestamp) >= rla.start_date
    AND (rla.end_date IS NULL OR COALESCE(ti.report_timestamp, tdc.report_timestamp) <= rla.end_date)
LEFT JOIN es_warehouse.public.locations l ON rla.location_id = l.location_id
LEFT JOIN es_warehouse.public.states s ON l.state_id = s.state_id
QUALIFY ROW_NUMBER() OVER (PARTITION BY ndl.notification_delivery_log_id ORDER BY l.location_id DESC NULLS LAST) = 1