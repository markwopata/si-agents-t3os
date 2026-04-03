SELECT
    dii._es_load_timestamp,
    dii.delivery_inventory_item_id,
    dii.inventory_item_name,
    dii.delivery_id,
    dii.inventory_item_quantity,
    dii.inventory_product_name_historical,
    dii.inventory_item_id,
    dii._es_update_timestamp
FROM {{ source('es_warehouse_public', 'delivery_inventory_items') }} as dii
