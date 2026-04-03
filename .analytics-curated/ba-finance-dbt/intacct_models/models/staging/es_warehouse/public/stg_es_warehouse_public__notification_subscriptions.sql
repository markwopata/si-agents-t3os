SELECT
    ns.notification_subscription_id,
    ns.subscription_group_id,
    ns.asset_incident_threshold_id,
    ns.time_fence_id,
    ns.geofence_subscription_id,
    ns.asset_id,
    ns.tracking_incident_type_id,
    ns.is_dtc,
    ns.created_at,
    ns.company_id,
    ns._es_update_timestamp
FROM {{ source('es_warehouse_public', 'notification_subscriptions') }} as ns
