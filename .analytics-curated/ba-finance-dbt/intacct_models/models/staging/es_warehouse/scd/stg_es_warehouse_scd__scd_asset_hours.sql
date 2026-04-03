SELECT
    sah.asset_scd_hours_id,
    sah.asset_id,
    sah.hours,
    sah.date_start,
    sah.date_end,
    sah.current_flag,
    sah._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_hours') }} as sah
