SELECT
    sasbv.asset_statuses_battery_voltage_id,
    sasbv.asset_id,
    sasbv.battery_voltage,
    sasbv.date_start,
    sasbv.date_end,
    sasbv.current_flag,
    sasbv._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_statuses_battery_voltage') }} as sasbv
