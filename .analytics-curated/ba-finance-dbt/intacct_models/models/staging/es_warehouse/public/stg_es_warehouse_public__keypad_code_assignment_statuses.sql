SELECT
    kcas.keypad_code_assignment_status_id,
    kcas.name,
    kcas.date_created,
    kcas._es_update_timestamp
FROM {{ source('es_warehouse_public', 'keypad_code_assignment_statuses') }} as kcas
