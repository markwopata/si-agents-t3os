SELECT
    wi.warranty_item_id,
    wi.warranty_id,
    wi.time_interval_id,
    wi.description,
    wi.date_deleted,
    wi.usage_unit_id,
    wi.usage_value,
    wi.time_unit_id,
    wi.time_value,
    wi.date_created,
    wi.date_updated,
    wi._es_update_timestamp
FROM {{ source('es_warehouse_public', 'warranty_items') }} as wi
