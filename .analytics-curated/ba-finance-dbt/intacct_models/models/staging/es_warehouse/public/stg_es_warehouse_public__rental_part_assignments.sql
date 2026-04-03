SELECT
    rpa.rental_part_assignment_id,
    rpa.rental_id,
    rpa.part_id,
    rpa.quantity,
    rpa.start_date,
    rpa.end_date,
    rpa.drop_off_delivery_id,
    rpa.return_delivery_id,
    rpa.from_inventory_transaction_id,
    rpa.to_inventory_transaction_id,
    rpa.quantity_returned,
    rpa.quantity_purchased,
    rpa.date_created,
    rpa.date_updated,
    rpa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_part_assignments') }} as rpa
