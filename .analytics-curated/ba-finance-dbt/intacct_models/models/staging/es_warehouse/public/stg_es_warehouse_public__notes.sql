SELECT
    n.note_id,
    n.content,
    n.create_date,
    n.update_date,
    n.created_by,
    n.updated_by,
    n._es_update_timestamp
FROM {{ source('es_warehouse_public', 'notes') }} as n
