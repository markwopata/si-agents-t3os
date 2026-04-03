SELECT
    bt.billing_type_id,
    bt.name,
    bt._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'billing_types') }} as bt
