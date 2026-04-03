SELECT
    sars.asset_id,
    sars.rental_status,
    sars.current_flag,
    sars.date_start,
    sars.date_end,
    sars._es_update_timestamp
FROM {{ source('es_warehouse_scd', 'scd_asset_rental_status') }} as sars
