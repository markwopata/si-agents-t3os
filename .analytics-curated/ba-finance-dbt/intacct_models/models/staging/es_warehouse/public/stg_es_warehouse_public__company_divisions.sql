SELECT
    cd.company_division_id,
    cd.name,
    cd.company_id,
    cd._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_divisions') }} as cd
