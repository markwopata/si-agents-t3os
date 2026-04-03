SELECT
    vool.asset_id,
    vool.out_of_lock_timestamp,
    vool.hours_out_of_lock,
    vool.over_72_hours_flag,
    vool.out_of_lock_reason,
    vool.unplugged_flag
FROM {{ source('es_warehouse_public', 'v_out_of_lock') }} as vool
