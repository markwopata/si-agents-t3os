SELECT
    aaaa._es_load_timestamp,
    aaaa.asset_alert_association_asset_id,
    aaaa.date_deactivated,
    aaaa.asset_alert_association_id,
    aaaa.asset_id,
    aaaa.date_created,
    aaaa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_association_assets') }} as aaaa
