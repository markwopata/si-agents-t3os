SELECT
    sad.scd_asset_driver_id,
    sad.asset_id,
    sad.driver_name,
    sad.user_id,
    sad.date_start,
    sad.date_end,
    sad.current_flag
FROM {{ source('es_warehouse_scd', 'scd_asset_driver') }} as sad
