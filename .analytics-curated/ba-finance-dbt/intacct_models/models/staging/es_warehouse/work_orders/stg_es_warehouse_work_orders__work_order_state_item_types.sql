SELECT
    wosit.work_order_state_item_type_id,
    wosit.name,
    wosit._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_state_item_types') }} as wosit
