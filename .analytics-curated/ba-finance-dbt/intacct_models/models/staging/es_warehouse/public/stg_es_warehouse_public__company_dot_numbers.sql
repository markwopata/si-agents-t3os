SELECT
    cdn.dot_number_id,
    cdn.dot_number,
    cdn.company_id,
    cdn.description,
    cdn.date_modified,
    cdn.date_deleted,
    cdn.date_created,
    cdn._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_dot_numbers') }} as cdn
