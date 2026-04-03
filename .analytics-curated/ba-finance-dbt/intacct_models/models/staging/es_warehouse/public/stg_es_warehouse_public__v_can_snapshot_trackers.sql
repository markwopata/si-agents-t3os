SELECT
    vcst.tracker_id,
    vcst.device_serial
FROM {{ source('es_warehouse_public', 'v_can_snapshot_trackers') }} as vcst
