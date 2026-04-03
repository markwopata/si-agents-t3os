SELECT
    sarr.asset_id,
    sarr.rapid_rent,
    sarr.deleted,
    sarr.current_flag,
    sarr.date_start,
    sarr.date_end,
    sarr._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_rapid_rent') }} as sarr
