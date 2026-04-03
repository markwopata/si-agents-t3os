SELECT
    kc.keypad_code_id,
    kc.code,
    kc.is_reserved,
    kc.master_code,
    kc.date_created,
    kc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'keypad_codes') }} as kc
