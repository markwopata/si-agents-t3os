SELECT
    nt.net_terms_id,
    nt.name,
    nt.days,
    nt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'net_terms') }} as nt
