SELECT
    woci.work_order_checklist_item_id,
    woci.task_id,
    woci.completed,
    woci.user_id,
    woci.work_order_id,
    woci.display_name,
    woci.priority,
    woci.note,
    woci.task_type_id,
    woci.required,
    woci.date_updated,
    woci._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_checklist_items') }} as woci
