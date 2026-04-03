SELECT
    tdc.tracking_diagnostic_codes_id,
    tdc.asset_id,
    tdc.report_timestamp,
    tdc.vendor_timestamp,
    tdc.code,
    tdc.last_seen,
    tdc.cleared,
    tdc.occurrences,
    tdc.level,
    tdc.failure_mode_identifier,
    tdc.module_identifier,
    tdc.suspect_parameter_number,
    tdc.tracking_event_id,
    tdc.tracking_obd_dtc_code_id,
    tdc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracking_diagnostic_codes') }} as tdc
