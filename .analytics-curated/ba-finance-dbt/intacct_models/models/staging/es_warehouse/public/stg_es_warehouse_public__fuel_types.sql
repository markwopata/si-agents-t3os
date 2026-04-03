SELECT
    ft.fuel_type_id,
    ft.name,
    ft.fuel_type_canonical_id,
    ft.date_created,
    ft._es_update_timestamp
FROM {{ source('es_warehouse_public', 'fuel_types') }} as ft
