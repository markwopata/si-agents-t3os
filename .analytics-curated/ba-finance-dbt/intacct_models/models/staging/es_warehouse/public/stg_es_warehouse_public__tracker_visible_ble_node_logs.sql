SELECT
    tvbnl.tracker_visible_ble_node_log_id,
    tvbnl.gateway_tracker_id,
    tvbnl.ble_node_tracker_id,
    tvbnl.enter_datetime,
    tvbnl.exit_datetime,
    tvbnl.date_created,
    tvbnl._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracker_visible_ble_node_logs') }} as tvbnl
