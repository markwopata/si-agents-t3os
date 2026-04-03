SELECT
    ple.price_list_entry_id,
    ple.created_by_id,
    ple.modified_by_id,
    ple.price_list_id,
    ple.item_id,
    ple.currency_code_id,
    ple.amount,
    ple.date_created,
    ple.date_updated,
    ple._es_update_timestamp
FROM {{ source('procurement_public', 'price_list_entries') }} as ple
