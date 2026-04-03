SELECT
    sau.asset_scd_user_id,
    sau.asset_id,
    sau.user_id,
    sau.date_start,
    sau.date_end,
    sau.current_flag,
    sau._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_users') }} as sau
