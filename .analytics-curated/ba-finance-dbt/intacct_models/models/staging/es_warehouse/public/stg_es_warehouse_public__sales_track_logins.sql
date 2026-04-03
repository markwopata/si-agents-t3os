SELECT
    stl.sales_track_login_id,
    stl.company_id,
    stl.login_link,
    stl.token,
    stl.date_added,
    stl.fleet_login_link,
    stl.analytics_login_link,
    stl._es_update_timestamp
FROM {{ source('es_warehouse_public', 'sales_track_logins') }} as stl
