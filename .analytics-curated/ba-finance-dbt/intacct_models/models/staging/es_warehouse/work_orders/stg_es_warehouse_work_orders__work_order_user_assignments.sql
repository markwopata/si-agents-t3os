SELECT
    woua.work_order_id,
    woua.work_order_user_assignment_type_id,
    woua.user_id,
    woua.start_date,
    woua.end_date,
    woua.work_order_user_assignment_id,
    woua.date_created,
    woua.date_updated,
    woua._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_user_assignments') }} as woua
