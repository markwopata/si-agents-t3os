SELECT
    awx.asset_warranty_xref_id,
    awx.warranty_id,
    awx.asset_id,
    awx.date_deleted,
    awx.date_created,
    awx.date_updated,
    awx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_warranty_xref') }} as awx
