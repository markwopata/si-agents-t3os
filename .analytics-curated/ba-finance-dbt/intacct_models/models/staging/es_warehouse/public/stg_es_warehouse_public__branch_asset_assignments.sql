SELECT
    baa.branch_asset_assignment_id,
    baa.branch_id,
    baa.asset_id,
    baa.start_date,
    baa.end_date,
    baa.branch_asset_assignment_type_id,
    baa.user_id,
    baa.date_created,
    baa._es_update_timestamp
FROM {{ source('es_warehouse_public', 'branch_asset_assignments') }} as baa
