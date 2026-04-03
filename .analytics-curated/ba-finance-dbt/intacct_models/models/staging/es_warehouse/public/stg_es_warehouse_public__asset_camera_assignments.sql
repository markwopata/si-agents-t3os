SELECT
    aca.asset_camera_id,
    aca.asset_id,
    aca.camera_id,
    aca.date_installed,
    aca.date_uninstalled,
    aca._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_camera_assignments') }} as aca
