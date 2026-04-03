SELECT
    wobt.date_completed,
    wobt.name,
    wobt.company_tag_id,
    wobt.first_name,
    wobt.last_name,
    wobt.user_id,
    wobt.work_order_id,
    wobt.user_assignment_start_date,
    wobt.user_assignment_end_date,
    wobt.date_created,
    wobt.date_updated
FROM {{ source('es_warehouse_work_orders', 'work_orders_by_tag') }} as wobt
