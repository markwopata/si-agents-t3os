SELECT
    poas._es_load_timestamp,
    poas.allocation_snapshot_id,
    poas.created_by_id,
    poas.allocation_name,
    poas.allocation_id,
    poas.allocation_type,
    poas.date_created,
    poas._es_update_timestamp
FROM {{ source('procurement_public', 'purchase_order_allocation_snapshot') }} as poas
