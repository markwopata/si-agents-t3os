SELECT
    fl.financial_lender_id,
    fl.name,
    fl._es_update_timestamp
FROM {{ source('es_warehouse_public', 'financial_lenders') }} as fl
