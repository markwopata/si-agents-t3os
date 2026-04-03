SELECT
    pc.pgn_category_id,
    pc.pgn_category_name,
    pc.pgn_category_desc
FROM {{ source('es_warehouse_public', 'pgn_category') }} as pc
