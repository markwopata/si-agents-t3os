SELECT
    rt.rental_type_id,
    rt.name,
    rt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_types') }} as rt
