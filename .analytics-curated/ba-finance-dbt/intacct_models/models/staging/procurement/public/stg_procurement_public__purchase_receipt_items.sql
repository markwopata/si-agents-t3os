SELECT
    pri._es_load_timestamp,
    pri.purchase_receipt_item_id,
    pri.accepted_quantity,
    pri.rejected_quantity,
    pri.purchase_receipt_id,
    pri.purchase_line_item_id,
    pri.modified_by_id,
    pri.created_by_id,
    pri.date_created,
    pri.date_updated,
    pri._es_update_timestamp
FROM {{ source('procurement_public', 'purchase_receipt_items') }} as pri
