SELECT
    wpc.purchase_code_id,
    wpc.short_purchase_code,
    wpc.purchase_code,
    wpc.description,
    wpc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'wex_purchase_codes') }} as wpc
