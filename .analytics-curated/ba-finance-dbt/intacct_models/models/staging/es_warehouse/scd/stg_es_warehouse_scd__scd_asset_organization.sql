SELECT
    sao.scd_asset_organization_id,
    sao.asset_id,
    sao.organization_id,
    sao.date_start,
    sao.date_end,
    sao.current_flag,
    sao._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_organization') }} as sao
