SELECT
    cdt.company_document_type_id,
    cdt.name,
    cdt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_document_types') }} as cdt
