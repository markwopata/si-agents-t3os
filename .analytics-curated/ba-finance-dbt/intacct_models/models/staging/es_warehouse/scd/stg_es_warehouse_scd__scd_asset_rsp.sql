SELECT
    sar.scd_asset_rsp_id,
    sar.asset_id,
    sar.rental_branch_id,
    sar.user_id,
    sar.date_start,
    sar.date_end,
    sar.current_flag,
    sar._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_rsp') }} as sar
