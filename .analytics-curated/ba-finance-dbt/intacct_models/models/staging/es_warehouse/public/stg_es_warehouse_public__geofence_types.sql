SELECT
    gt.geofence_type_id,
    gt.name,
    gt.geofence_type_canonical_id,
    gt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'geofence_types') }} as gt
