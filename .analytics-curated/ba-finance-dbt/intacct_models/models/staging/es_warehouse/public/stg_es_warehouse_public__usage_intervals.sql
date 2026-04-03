SELECT
    ui.usage_interval_id,
    ui.unit_id,
    ui.value,
    ui.date_created,
    ui.date_updated,
    ui._es_update_timestamp
FROM {{ source('es_warehouse_public', 'usage_intervals') }} as ui
