SELECT
    kca.keypad_code_assignment_id,
    kca.keypad_id,
    kca.keypad_code_id,
    kca.start_date,
    kca.end_date,
    kca.keypad_code_assignment_status_id,
    kca.company_keypad_code_id,
    kca.is_local_code,
    kca.date_created,
    kca._es_update_timestamp
FROM {{ source('es_warehouse_public', 'keypad_code_assignments') }} as kca
