SELECT
    aaat._es_load_timestamp,
    aaat.asset_alert_association_type_id,
    aaat.name,
    aaat.date_created,
    aaat._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_association_types') }} as aaat
