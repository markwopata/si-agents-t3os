SELECT
    ool7dr.asset_id,
    ool7dr.out_of_lock_timestamp,
    ool7dr.hours_out_of_lock,
    ool7dr.over_72_hours_flag,
    ool7dr.out_of_lock_reason,
    ool7dr.unplugged_flag,
    ool7dr.company_id,
    ool7dr.snapshot_date
FROM {{ source('es_warehouse_public', 'out_of_lock_7_days_rolling') }} as ool7dr
