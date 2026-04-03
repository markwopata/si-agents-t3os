SELECT
    hf.asset_scd_hours_id,
    hf.asset_id,
    hf.hours,
    hf.date_start,
    hf.date_end,
    hf._es_update_timestamp
FROM {{ source('es_warehouse_public', 'hours_fix') }} as hf
