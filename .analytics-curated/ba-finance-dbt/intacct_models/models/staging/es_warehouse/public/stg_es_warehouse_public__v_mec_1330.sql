SELECT
    vm1.device_serial,
    vm1.tracker_type_id,
    vm1.tracker_id,
    vm1.asset_id
FROM {{ source('es_warehouse_public', 'v_mec_1330') }} as vm1
