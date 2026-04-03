SELECT
    emtx.equipment_model_tag_xref_id,
    emtx.equipment_model_id,
    emtx.tag_id,
    emtx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'equipment_model_tag_xref') }} as emtx
