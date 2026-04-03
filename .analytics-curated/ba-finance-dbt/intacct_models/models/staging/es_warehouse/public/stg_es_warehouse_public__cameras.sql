SELECT
    c.camera_id,
    c.device_serial,
    c.camera_vendor_id,
    c.number_of_feeds,
    c.created,
    c.updated,
    c.vendor_camera_id,
    c.phone_number,
    c.iccid,
    c.company_id,
    c._es_update_timestamp
FROM {{ source('es_warehouse_public', 'cameras') }} as c
