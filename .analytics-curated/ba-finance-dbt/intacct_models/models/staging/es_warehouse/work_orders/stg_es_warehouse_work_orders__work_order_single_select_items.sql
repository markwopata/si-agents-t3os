SELECT
    wossi.work_order_single_select_item_id,
    wossi.selection_id,
    wossi.task_id,
    wossi.task_type_id,
    wossi.note,
    wossi.display_name,
    wossi.priority,
    wossi.required,
    wossi.user_id,
    wossi.work_order_id,
    wossi.date_updated,
    wossi._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_single_select_items') }} as wossi
