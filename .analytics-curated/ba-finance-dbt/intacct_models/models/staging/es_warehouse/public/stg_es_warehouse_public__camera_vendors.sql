SELECT
    cv.camera_vendor_id,
    cv.name,
    cv._es_update_timestamp
FROM {{ source('es_warehouse_public', 'camera_vendors') }} as cv
