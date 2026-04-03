SELECT
    todc.tracking_obd_dtc_code_id,
    todc.code,
    todc.description,
    todc.manufacturer,
    todc._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracking_obd_dtc_codes') }} as todc
