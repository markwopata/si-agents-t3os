SELECT
    wout.work_order_user_time_id,
    wout.work_order_id,
    wout.user_id,
    wout.start_date,
    wout.end_date,
    wout.description,
    wout.created_by_user_id,
    wout.updated_by_user_id,
    wout.date_deleted,
    wout.date_created,
    wout.date_updated,
    wout._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_user_times') }} as wout
