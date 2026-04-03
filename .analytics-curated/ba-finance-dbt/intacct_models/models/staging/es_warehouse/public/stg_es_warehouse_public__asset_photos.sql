SELECT
    ap._es_load_timestamp,
    ap.asset_id,
    ap.photo_id,
    ap._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_photos') }} as ap
