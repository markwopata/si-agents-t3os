SELECT
    suldpi.user_scd_link_device_push_id,
    suldpi.user_id,
    suldpi.link_device_push_id,
    suldpi.date_start,
    suldpi.date_end,
    suldpi.current_flag,
    suldpi._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_users_link_device_push_id') }} as suldpi
