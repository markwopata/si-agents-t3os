SELECT
    tt.trip_type_id,
    tt.name,
    tt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'trip_types') }} as tt
