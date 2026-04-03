SELECT
    tprc.third_party_rental_cost_id,
    tprc.third_party_rental_id,
    tprc.third_party_rental_cost_type_id,
    tprc.notes,
    tprc.amount,
    tprc.date_created,
    tprc.date_updated,
    tprc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'third_party_rental_costs') }} as tprc
