SELECT
    rs.rental_status_id,
    rs.name,
    rs._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_statuses') }} as rs
