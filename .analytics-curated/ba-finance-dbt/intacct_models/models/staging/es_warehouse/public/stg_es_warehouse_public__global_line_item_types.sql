SELECT
    glit.domain_id,
    glit.line_item_type_id,
    glit.name,
    glit._es_update_timestamp
FROM {{ source('es_warehouse_public', 'global_line_item_types') }} as glit
