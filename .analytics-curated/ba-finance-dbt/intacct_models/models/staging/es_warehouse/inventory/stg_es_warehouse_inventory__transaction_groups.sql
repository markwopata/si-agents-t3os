SELECT
    tg.transaction_group_id,
    tg.memo,
    tg.custom_id,
    tg.date_created,
    tg.date_updated,
    tg._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'transaction_groups') }} as tg
