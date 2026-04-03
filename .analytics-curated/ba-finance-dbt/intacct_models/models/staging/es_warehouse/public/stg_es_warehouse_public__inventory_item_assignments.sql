SELECT
    iia._es_load_timestamp,
    iia.inventory_item_assignment_id,
    iia.return_delivery_id,
    iia.inventory_item_name,
    iia.inventory_item_quantity,
    iia.inventory_item_quantity_returned,
    iia.inventory_item_quantity_purchased,
    iia.inventory_location_id,
    iia.inventory_item_id,
    iia.rental_id,
    iia.end_date,
    iia.start_date,
    iia.drop_off_delivery_id,
    iia.date_created,
    iia.date_updated,
    iia._es_update_timestamp
FROM {{ source('es_warehouse_public', 'inventory_item_assignments') }} as iia
