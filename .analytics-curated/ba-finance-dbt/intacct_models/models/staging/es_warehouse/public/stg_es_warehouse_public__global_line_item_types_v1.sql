SELECT
    glitv.domain_id,
    glitv.line_item_type_id,
    glitv.name,
    glitv._es_update_timestamp
FROM {{ source('es_warehouse_public', 'global_line_item_types_v1') }} as glitv
