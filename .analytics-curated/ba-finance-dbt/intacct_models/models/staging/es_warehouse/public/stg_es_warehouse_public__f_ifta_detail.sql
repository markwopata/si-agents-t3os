SELECT
    fid.company_id,
    fid.custom_name,
    fid.make,
    fid.model,
    fid.name,
    fid.state_entry,
    fid.state_exit,
    fid.start_odometer,
    fid.end_odometer,
    fid.miles_driven,
    fid.start_lat,
    fid.start_lon,
    fid.end_lat,
    fid.end_lon
FROM {{ source('es_warehouse_public', 'f_ifta_detail') }} as fid
