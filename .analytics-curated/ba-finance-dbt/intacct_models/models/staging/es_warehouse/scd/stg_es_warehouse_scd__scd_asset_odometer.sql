SELECT
    sao.asset_scd_odometer_id,
    sao.asset_id,
    sao.odometer,
    sao.date_start,
    sao.date_end,
    sao.current_flag,
    sao._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_odometer') }} as sao
