SELECT
    aiift.asset_inspection_item_fail_type_id,
    aiift.name,
    aiift._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_inspection_item_fail_types') }} as aiift
