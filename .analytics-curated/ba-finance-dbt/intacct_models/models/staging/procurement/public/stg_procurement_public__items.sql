SELECT
    i.item_id,
    i.preferred_vendor_id,
    i.sellable,
    i.buyable,
    i.company_id,
    i.created_by_id,
    i.modified_by_id,
    i.item_type,
    i.duplicate_of_id,
    i.date_created,
    i.date_updated,
    i.date_archived,
    i._es_update_timestamp
FROM {{ source('procurement_public', 'items') }} as i
