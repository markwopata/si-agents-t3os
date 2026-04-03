SELECT
    sam.scd_asset_msp_id,
    sam.asset_id,
    sam.service_branch_id,
    sam.user_id,
    sam.date_start,
    sam.date_end,
    sam.current_flag,
    sam._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_msp') }} as sam
