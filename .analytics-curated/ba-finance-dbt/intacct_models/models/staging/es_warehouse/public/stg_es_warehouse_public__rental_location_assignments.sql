SELECT
    rla.created_by_user_id,
    rla.location_id,
    rla.end_date,
    rla.rental_location_assignment_id,
    rla.rental_id,
    rla.start_date,
    rla.move_delivery_id,
    rla.date_created,
    rla.date_updated,
    rla._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_location_assignments') }} as rla
