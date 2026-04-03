SELECT
    w.warranty_id,
    w.company_id,
    w.description,
    w.date_deleted,
    w.note,
    w.date_created,
    w.date_updated,
    w._es_update_timestamp
FROM {{ source('es_warehouse_public', 'warranties') }} as w
