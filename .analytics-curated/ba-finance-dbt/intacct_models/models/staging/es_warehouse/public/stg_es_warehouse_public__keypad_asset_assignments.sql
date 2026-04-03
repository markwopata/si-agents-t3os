SELECT
    kaa.keypad_asset_assignment_id,
    kaa.keypad_id,
    kaa.asset_id,
    kaa.start_date,
    kaa.end_date,
    kaa.date_created,
    kaa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'keypad_asset_assignments') }} as kaa
