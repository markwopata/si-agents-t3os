SELECT
    cn.company_note_id,
    cn.company_id,
    cn.user_id,
    cn.note_type_id,
    cn.note_description,
    cn.note_text,
    cn.date_created,
    cn._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_notes') }} as cn
