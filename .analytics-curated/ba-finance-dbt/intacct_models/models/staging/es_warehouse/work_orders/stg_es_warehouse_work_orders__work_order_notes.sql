SELECT
    won.work_order_note_id,
    won.work_order_id,
    won.note,
    won.creator_user_id,
    won.archived_date,
    won.date_created,
    won.date_updated,
    won._es_update_timestamp
FROM {{ source('es_warehouse_work_orders', 'work_order_notes') }} as won
