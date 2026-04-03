SELECT
    wosso.work_order_single_select_option_id,
    wosso.work_order_single_select_item_id,
    wosso.task_select_option_id,
    wosso.display_name,
    wosso._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_single_select_options') }} as wosso
