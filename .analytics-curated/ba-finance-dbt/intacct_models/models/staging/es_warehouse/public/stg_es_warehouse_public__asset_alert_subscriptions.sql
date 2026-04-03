SELECT
    aas._es_load_timestamp,
    aas.asset_alert_subscription_id,
    aas.date_deactivated,
    aas.user_id,
    aas.asset_alert_rule_id,
    aas.date_created,
    aas._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_subscriptions') }} as aas
