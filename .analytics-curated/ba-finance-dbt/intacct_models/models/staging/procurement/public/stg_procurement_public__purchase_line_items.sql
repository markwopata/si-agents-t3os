SELECT
    pli._es_load_timestamp,
    pli.purchase_line_item_id,
    pli.total_rejected,
    pli.total_accepted,
    pli.quantity,
    pli.allocation_snapshot_id,
    pli.item_snapshot_id,
    pli.allocation_id,
    pli.memo,
    pli.description,
    pli.price_per_unit,
    pli.item_id,
    pli.allocation_type,
    pli.purchase_id,
    pli.date_archived,
    pli._es_update_timestamp
FROM {{ source('procurement_public', 'purchase_line_items') }} as pli
