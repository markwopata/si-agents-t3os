SELECT
    ac.consumable_id,
    ac.asset_id,
    ac.asset_consumable_id,
    ac._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_consumables') }} as ac
