SELECT
    woe.work_order_event_id,
    woe.entity_id,
    woe.action,
    woe.event_time,
    woe.changes,
    woe.user_id,
    woe.date_created,
    woe._es_update_timestamp,
    woe.changes:"archived_date" AS changes__archived_date,
    woe.changes:"work_order_status_id" AS changes__work_order_status_id,
    woe.changes:"billing_type_id" AS changes__billing_type_id
FROM {{ source('es_warehouse_work_orders', 'work_order_events') }} as woe
