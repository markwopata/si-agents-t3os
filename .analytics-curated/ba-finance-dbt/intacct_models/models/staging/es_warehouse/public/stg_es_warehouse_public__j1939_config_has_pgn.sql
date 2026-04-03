SELECT
    jchp.j1939_config_id,
    jchp.pgn_id
FROM {{ source('es_warehouse_public', 'j1939_config_has_pgn') }} as jchp
