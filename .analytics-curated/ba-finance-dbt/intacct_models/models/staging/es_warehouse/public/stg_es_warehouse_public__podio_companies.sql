SELECT
    pc.company_id,
    pc.name,
    pc.street_address,
    pc.owner_name,
    pc.phone_number,
    pc.net_terms
FROM {{ source('es_warehouse_public', 'podio_companies') }} as pc
