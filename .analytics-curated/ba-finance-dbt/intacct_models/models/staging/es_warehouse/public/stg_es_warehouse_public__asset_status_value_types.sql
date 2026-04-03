SELECT
    asvt.asset_status_value_type_id,
    asvt.name,
    asvt.asset_status_value_type_canonical_id,
    asvt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_status_value_types') }} as asvt
