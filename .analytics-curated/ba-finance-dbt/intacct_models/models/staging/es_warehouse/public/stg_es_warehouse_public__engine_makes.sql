SELECT
    em.engine_make_id,
    em.engine_make_name,
    em._es_update_timestamp
FROM {{ source('es_warehouse_public', 'engine_makes') }} as em
