SELECT
    wos.work_order_status_id,
    wos.name,
    wos._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_statuses') }} as wos
