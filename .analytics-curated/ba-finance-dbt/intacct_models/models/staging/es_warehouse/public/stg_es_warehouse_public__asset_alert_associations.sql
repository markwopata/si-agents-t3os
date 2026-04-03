SELECT
    aaa._es_load_timestamp,
    aaa.asset_alert_association_id,
    aaa.organization_id,
    aaa.asset_alert_association_type_id,
    aaa.branch_id,
    aaa.purchase_order_id,
    aaa.date_deactivated,
    aaa.inventory_branch,
    aaa.rental_branch,
    aaa.asset_type_id,
    aaa.asset_alert_rule_id,
    aaa.geofence_id,
    aaa.rental_location_id,
    aaa.service_branch,
    aaa.date_created,
    aaa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_alert_associations') }} as aaa
