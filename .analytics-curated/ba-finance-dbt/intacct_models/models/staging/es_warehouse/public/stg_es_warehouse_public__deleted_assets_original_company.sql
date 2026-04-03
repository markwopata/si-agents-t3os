SELECT
    daoc.deleted_assets_original_company_id,
    daoc.asset_id,
    daoc.company_id,
    daoc.date_created,
    daoc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'deleted_assets_original_company') }} as daoc
