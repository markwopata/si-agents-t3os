SELECT
    parr.payment_application_reversal_reason_id,
    parr.active,
    parr.description,
    parr._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payment_application_reversal_reasons') }} as parr
