SELECT
    wd.warranty_document_id,
    wd.warranty_id,
    wd.url,
    wd.date_deleted,
    wd.date_created,
    wd.date_updated,
    wd._es_update_timestamp
FROM {{ source('es_warehouse_public', 'warranty_documents') }} as wd
