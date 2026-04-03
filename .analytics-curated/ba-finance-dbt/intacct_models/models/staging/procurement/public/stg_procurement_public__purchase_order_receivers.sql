SELECT
    por.purchase_order_receiver_id,
    por.purchase_order_id,
    por.store_id,
    por.receiver_type,
    por.created_by_id,
    por.modified_by_id,
    por.date_received,
    por.note,
    por.transaction_id,
    por.date_created,
    por.date_updated,
    por._es_update_timestamp
FROM {{ source('procurement_public', 'purchase_order_receivers') }} as por
