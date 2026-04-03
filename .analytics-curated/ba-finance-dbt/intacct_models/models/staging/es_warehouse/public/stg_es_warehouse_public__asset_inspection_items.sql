SELECT
    aii.asset_inspection_item_id,
    aii.asset_inspection_id,
    aii.passed,
    aii.asset_inspection_item_fail_type_id,
    aii.notes,
    aii.created,
    aii.create_user_id,
    aii.resolved,
    aii.resolved_user_id,
    aii.resolved_notes,
    aii.resolved_timestamp,
    aii._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_inspection_items') }} as aii
