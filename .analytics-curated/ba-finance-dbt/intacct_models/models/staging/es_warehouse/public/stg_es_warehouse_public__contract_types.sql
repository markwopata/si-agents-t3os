SELECT
    ct.contract_type_id,
    ct.name,
    ct._es_update_timestamp
FROM {{ source('es_warehouse_public', 'contract_types') }} as ct
