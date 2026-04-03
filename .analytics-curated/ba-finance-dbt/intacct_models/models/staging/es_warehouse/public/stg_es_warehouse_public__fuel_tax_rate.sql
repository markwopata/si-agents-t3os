SELECT
    ftr.fuel_tax_rate_id,
    ftr.state_id,
    ftr.gasoline_rate,
    ftr.date_created,
    ftr._es_update_timestamp
FROM {{ source('es_warehouse_public', 'fuel_tax_rate') }} as ftr
