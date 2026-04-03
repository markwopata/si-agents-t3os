SELECT
    ata.asset_tracker_id,
    ata.asset_id,
    ata.tracker_id,
    ata.date_installed,
    ata.date_uninstalled,
    ata.company_id,
    ata._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_tracker_assignments') }} as ata
