SELECT
    dcr._es_load_timestamp,
    dcr.dispute_credit_reason_id,
    dcr.active,
    dcr.description,
    dcr._es_update_timestamp
FROM {{ source('es_warehouse_public', 'dispute_credit_reasons') }} as dcr
