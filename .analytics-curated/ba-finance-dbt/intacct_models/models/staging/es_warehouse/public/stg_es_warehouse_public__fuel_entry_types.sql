SELECT
    fet.fuel_entry_type_id,
    fet.name,
    fet.fuel_entry_type_canonical_id,
    fet.date_created,
    fet._es_update_timestamp
FROM {{ source('es_warehouse_public', 'fuel_entry_types') }} as fet
