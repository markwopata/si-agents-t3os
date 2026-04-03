SELECT
    woct.work_order_id,
    woct.company_tag_id,
    woct._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_company_tags') }} as woct
