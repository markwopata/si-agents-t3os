SELECT
    k.keypad_id,
    k.serial_number,
    k.asset_id,
    k.date_created,
    k._es_update_timestamp
FROM {{ source('es_warehouse_public', 'keypads') }} as k
