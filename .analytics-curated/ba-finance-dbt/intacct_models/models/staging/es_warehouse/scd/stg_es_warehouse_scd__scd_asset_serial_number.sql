SELECT
    sasn.asset_id,
    sasn.serial_number,
    sasn.deleted,
    sasn.current_flag,
    sasn.date_start,
    sasn.date_end,
    sasn._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_serial_number') }} as sasn
