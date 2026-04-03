SELECT
    woti.work_order_text_item_id,
    woti.text,
    woti.task_id,
    woti.task_type_id,
    woti.note,
    woti.display_name,
    woti.priority,
    woti.required,
    woti.user_id,
    woti.work_order_id,
    woti.date_updated,
    woti._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_text_items') }} as woti
