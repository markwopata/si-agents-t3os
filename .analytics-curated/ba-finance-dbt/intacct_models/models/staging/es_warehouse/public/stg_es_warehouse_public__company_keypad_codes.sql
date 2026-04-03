SELECT
    ckc.company_keypad_code_id,
    ckc.name,
    ckc.user_id,
    ckc.company_id,
    ckc.keypad_code_id,
    ckc.date_deactivated,
    ckc.rental_default,
    ckc.date_created,
    ckc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'company_keypad_codes') }} as ckc
