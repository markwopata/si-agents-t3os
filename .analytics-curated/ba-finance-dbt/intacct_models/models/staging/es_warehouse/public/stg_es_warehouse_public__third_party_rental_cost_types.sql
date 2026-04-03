SELECT
    tprct.third_party_rental_cost_type_id,
    tprct.name,
    tprct._es_update_timestamp
FROM {{ source('es_warehouse_public', 'third_party_rental_cost_types') }} as tprct
