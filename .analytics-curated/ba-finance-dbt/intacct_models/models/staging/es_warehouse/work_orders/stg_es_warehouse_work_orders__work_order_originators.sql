SELECT
    woo.work_order_originator_id,
    woo.work_order_id,
    woo.originator_type_id,
    woo.originator_id,
    woo.originator_item_id,
    woo.originator_uuid,
    woo.originator_item_uuid,
    woo._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_originators') }} as woo
