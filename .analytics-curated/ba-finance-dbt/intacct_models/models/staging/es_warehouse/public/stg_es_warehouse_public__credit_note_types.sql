SELECT
    cnt.credit_note_type_id,
    cnt.name as credit_note_type_name,
    cnt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'credit_note_types') }} as cnt
