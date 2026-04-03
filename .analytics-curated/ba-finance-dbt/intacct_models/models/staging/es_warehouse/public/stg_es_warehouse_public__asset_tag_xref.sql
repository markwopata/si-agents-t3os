SELECT
    atx.asset_tag_xref_id,
    atx.asset_id,
    atx.tag_id,
    atx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_tag_xref') }} as atx
