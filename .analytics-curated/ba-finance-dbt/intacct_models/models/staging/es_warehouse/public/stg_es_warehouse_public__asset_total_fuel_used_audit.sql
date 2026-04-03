SELECT
    atfua._es_load_timestamp,
    atfua.asset_total_fuel_used_audit_id,
    atfua.asset_id,
    atfua.new_total_fuel_used,
    atfua.old_total_fuel_used,
    atfua.created,
    atfua.asset_update_type_id,
    atfua.tracking_event_id,
    atfua._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_total_fuel_used_audit') }} as atfua
