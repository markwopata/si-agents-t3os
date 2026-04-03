SELECT
    rpo.rental_purchase_option_id,
    rpo.name,
    rpo._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_purchase_options') }} as rpo
