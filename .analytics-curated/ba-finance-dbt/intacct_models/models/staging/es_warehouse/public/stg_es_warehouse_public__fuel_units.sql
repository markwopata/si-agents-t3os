SELECT
    fu.fuel_unit_id,
    fu.name,
    fu.fuel_unit_canonical_id,
    fu.date_created,
    fu._es_update_timestamp
FROM {{ source('es_warehouse_public', 'fuel_units') }} as fu
