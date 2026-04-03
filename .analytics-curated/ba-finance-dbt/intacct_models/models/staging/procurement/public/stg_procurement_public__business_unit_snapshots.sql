SELECT
    bus._es_load_timestamp,
    bus.business_unit_snapshot_id,
    bus.name,
    bus.created_at,
    bus.business_unit_type,
    bus.business_unit_id,
    bus._es_update_timestamp
FROM {{ source('procurement_public', 'business_unit_snapshots') }} as bus
