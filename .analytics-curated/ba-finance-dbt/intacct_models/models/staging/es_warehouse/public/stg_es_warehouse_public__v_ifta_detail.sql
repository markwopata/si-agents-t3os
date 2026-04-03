SELECT
    vid.company_id,
    vid.asset_id,
    vid.custom_name,
    vid.make,
    vid.model,
    vid.name,
    vid.state_entry,
    vid.state_exit,
    vid.start_odometer,
    vid.end_odometer,
    vid.miles_driven,
    vid.start_lat,
    vid.start_lon,
    vid.end_lat,
    vid.end_lon
FROM {{ source('es_warehouse_public', 'v_ifta_detail') }} as vid
