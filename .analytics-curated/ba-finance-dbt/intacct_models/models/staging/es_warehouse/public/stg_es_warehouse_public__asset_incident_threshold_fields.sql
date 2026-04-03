SELECT
    aitf.asset_incident_threshold_field_id,
    aitf.description,
    aitf.event_field_name,
    aitf.asset_incident_threshold_field_unit_id,
    aitf.debounce_number,
    aitf.date_created,
    aitf._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_incident_threshold_fields') }} as aitf
