SELECT
    tt.description,
    tt.image,
    tt.name,
    tt.tracker_type_id,
    tt.tracker_vendor_id,
    tt.is_ble_node,
    tt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracker_types') }} as tt
