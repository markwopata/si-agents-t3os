SELECT
    s.state_id,
    s.abbreviation,
    s.name,
    s.geom2,
    s.geom,
    s.geom3,
    s._es_update_timestamp
FROM {{ source('es_warehouse_public', 'states') }} as s
