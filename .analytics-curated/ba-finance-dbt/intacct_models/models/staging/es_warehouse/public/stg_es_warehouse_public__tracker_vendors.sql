SELECT
    tv.tracker_vendor_id,
    tv.name,
    tv._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracker_vendors') }} as tv
