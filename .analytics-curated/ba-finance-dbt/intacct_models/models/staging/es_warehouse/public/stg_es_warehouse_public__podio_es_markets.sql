SELECT
    pem.company_id,
    pem.market_id,
    pem.market_name
FROM {{ source('es_warehouse_public', 'podio_es_markets') }} as pem
