SELECT
    phau.asset_id
FROM {{ source('es_warehouse_public', 'postgres_hourly_asset_usage') }} as phau
