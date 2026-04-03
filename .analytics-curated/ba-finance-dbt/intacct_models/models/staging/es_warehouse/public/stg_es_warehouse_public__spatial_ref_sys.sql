SELECT
    srs.srid,
    srs.auth_name,
    srs.auth_srid,
    srs.srtext,
    srs.proj4text,
    srs._es_update_timestamp
FROM {{ source('es_warehouse_public', 'spatial_ref_sys') }} as srs
