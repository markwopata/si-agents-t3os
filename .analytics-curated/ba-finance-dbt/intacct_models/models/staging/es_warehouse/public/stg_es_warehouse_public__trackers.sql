SELECT
    t.tracker_id,
    t.device_serial,
    t.vendor_id,
    t.company_id,
    t.phone_number,
    t.tracker_type_id,
    t.created,
    t.updated,
    t.battery_voltage_type_id,
    t.twilio_sid,
    t.iccid,
    t._es_update_timestamp
FROM {{ source('es_warehouse_public', 'trackers') }} as t
