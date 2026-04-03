SELECT
    ist.item_status_id,
    ist.name,
    ist._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'item_statuses') }} as ist
