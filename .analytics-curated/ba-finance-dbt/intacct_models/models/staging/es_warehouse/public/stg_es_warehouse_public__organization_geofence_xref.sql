SELECT
    ogx.organization_geofence_xref_id,
    ogx.organization_id,
    ogx.geofence_id,
    ogx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'organization_geofence_xref') }} as ogx
