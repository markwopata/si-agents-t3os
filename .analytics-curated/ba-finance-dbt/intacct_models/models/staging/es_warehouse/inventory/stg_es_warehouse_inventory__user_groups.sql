SELECT
    ug.user_group_id,
    ug.user_id,
    ug.group_id,
    ug.date_created,
    ug.date_updated,
    ug._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'user_groups') }} as ug
