SELECT
    p.pgn_id,
    p.pgn,
    p.pgn_category_id,
    p.format_spn,
    p.format_value,
    p.pgn_acronym,
    p.pgn_data_length,
    p.pgn_desc,
    p.pgn_label,
    p.pgn_transmission_rate,
    p.multiplex_spn
FROM {{ source('es_warehouse_public', 'pgn') }} as p
