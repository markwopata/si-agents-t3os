SELECT
    pr._es_load_timestamp,
    pr.purchase_receipt_id,
    pr.note,
    pr.store_id,
    pr.purchase_id,
    pr.date_received,
    pr.transaction_id,
    pr.modified_by_id,
    pr.created_by_id,
    pr.date_created,
    pr.date_updated,
    pr._es_update_timestamp
FROM {{ source('procurement_public', 'purchase_receipts') }} as pr
