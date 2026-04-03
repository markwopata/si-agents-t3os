SELECT
    ppt.payout_program_type_id,
    ppt.name,
    ppt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payout_program_types') }} as ppt
