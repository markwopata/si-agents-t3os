SELECT
    wosi.work_order_state_item_id,
    wosi.work_order_state_item_type_id,
    wosi.task_id,
    wosi.task_type_id,
    wosi.note,
    wosi.display_name,
    wosi.priority,
    wosi.user_id,
    wosi.work_order_id,
    wosi.required,
    wosi.date_updated,
    wosi._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_state_items') }} as wosi
