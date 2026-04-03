SELECT
    pu.user_id,
    pu.first_name,
    pu.last_name,
    pu.company_id,
    pu.company_name,
    pu.phone_number,
    pu.email_address,
    pu.username,
    pu.location_id,
    pu.nickname
FROM {{ source('es_warehouse_public', 'podio_users') }} as pu
