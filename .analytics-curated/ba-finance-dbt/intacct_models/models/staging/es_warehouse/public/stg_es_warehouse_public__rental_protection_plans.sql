SELECT
    rpp.rental_protection_plan_id,
    rpp.name,
    rpp.percent,
    rpp.expiry_date,
    rpp.rental_protection_plan_type_id,
    rpp.created_date,
    rpp._es_update_timestamp
FROM {{ source('es_warehouse_public', 'rental_protection_plans') }} as rpp
