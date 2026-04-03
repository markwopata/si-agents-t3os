SELECT
    aar.asset_alert_rule_id,
    aar.name,
    aar.company_id,
    aar.date_deactivated,
    aar.date_created,
    aar._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_rules') }} as aar
