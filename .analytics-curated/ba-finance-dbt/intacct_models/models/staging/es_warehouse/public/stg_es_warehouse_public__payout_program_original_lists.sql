SELECT
    ppol.original_list_id,
    ppol._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payout_program_original_lists') }} as ppol
