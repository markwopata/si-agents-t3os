SELECT
    tdaoc.asset_id,
    tdaoc.report_timestamp,
    tdaoc.vendor_timestamp,
    tdaoc.code,
    tdaoc.last_seen,
    tdaoc.cleared,
    tdaoc.occurrences,
    tdaoc.level,
    tdaoc.failure_mode_identifier,
    tdaoc.module_identifier,
    tdaoc.suspect_parameter_number,
    tdaoc.tracking_event_id,
    tdaoc.tracking_obd_dtc_code_id,
    tdaoc.description,
    tdaoc.manufacturer
FROM {{ source('es_warehouse_public', 'tracking_diagnostic_and_obd_codes') }} as tdaoc
