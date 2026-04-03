SELECT
    pps.payout_program_schedule_id,
    pps._es_update_timestamp
FROM {{ source('es_warehouse_public', 'payout_program_schedules') }} as pps
