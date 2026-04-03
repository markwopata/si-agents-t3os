SELECT
    oax.organization_asset_xref_id,
    oax.organization_id,
    oax.asset_id,
    oax.date_created,
    oax._es_update_timestamp
FROM {{ source('es_warehouse_public', 'organization_asset_xref') }} as oax
