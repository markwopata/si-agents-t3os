SELECT
    ono.order_note_id,
    ono.order_id,
    ono.content,
    ono.created_by_user_id,
    ono.date_created,
    ono._es_update_timestamp
FROM {{ source('es_warehouse_public', 'order_notes') }} as ono
