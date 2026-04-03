SELECT
    phs.pgn_id,
    phs.spn,
    phs.position
FROM {{ source('es_warehouse_public', 'pgn_has_spn') }} as phs
