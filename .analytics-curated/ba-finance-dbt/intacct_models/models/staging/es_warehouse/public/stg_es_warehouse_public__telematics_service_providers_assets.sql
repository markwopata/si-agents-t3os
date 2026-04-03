SELECT
    tspa.telematics_service_providers_asset_id,
    tspa.company_id,
    tspa.asset_id,
    tspa.date_start,
    tspa.date_end,
    tspa.date_created,
    tspa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'telematics_service_providers_assets') }} as tspa
