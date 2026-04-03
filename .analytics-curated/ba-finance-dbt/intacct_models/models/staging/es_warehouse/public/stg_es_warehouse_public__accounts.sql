SELECT
    a.account_id,
    a.google_account_id,
    a."type",
    a.email,
    a.username,
    a.is_active,
    a.first_name,
    a.last_name,
    a.picture,
    a.description,
    a.hashed_password,
    a.date_created,
    a.date_updated
FROM {{ source('es_warehouse_public', 'accounts') }} as a
