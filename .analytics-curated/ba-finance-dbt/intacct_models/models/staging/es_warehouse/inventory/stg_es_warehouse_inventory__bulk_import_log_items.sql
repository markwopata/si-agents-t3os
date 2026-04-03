SELECT
    bili.bulk_import_log_item_id,
    bili.object_id,
    bili.object_type_id,
    bili.bulk_import_session_id,
    bili._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'bulk_import_log_items') }} as bili
