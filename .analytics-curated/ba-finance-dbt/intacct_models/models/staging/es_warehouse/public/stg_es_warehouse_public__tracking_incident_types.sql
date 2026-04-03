SELECT
    tit.tracking_incident_type_id,
    tit.name,
    tit.alertable,
    tit.request_image,
    tit.request_video,
    tit._es_update_timestamp
FROM {{ source('es_warehouse_public', 'tracking_incident_types') }} as tit
