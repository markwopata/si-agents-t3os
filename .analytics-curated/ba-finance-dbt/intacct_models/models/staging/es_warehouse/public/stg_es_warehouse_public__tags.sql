SELECT
    t.tag_id,
    t.name,
    t._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tags') }} as t
