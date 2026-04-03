SELECT
    aact._es_load_timestamp,
    aact.asset_alert_condition_type_id,
    aact.name,
    aact.date_created,
    aact._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_condition_types') }} as aact
