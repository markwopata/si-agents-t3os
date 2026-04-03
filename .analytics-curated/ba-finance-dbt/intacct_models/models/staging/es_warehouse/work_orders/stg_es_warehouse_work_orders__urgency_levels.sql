SELECT
    ul.urgency_level_id,
    ul.name,
    ul._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'urgency_levels') }} as ul
