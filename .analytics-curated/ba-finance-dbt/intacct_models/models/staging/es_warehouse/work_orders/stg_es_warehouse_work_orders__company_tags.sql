SELECT
    ct.company_tag_id,
    ct.name,
    ct.company_id,
    ct.color,
    ct._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'company_tags') }} as ct
