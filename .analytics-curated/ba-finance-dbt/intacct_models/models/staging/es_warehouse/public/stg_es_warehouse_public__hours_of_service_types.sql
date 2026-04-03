SELECT
    host.hours_of_service_type_id,
    host.name,
    host.display_name,
    host._es_update_timestamp
FROM {{ source('es_warehouse_public', 'hours_of_service_types') }} as host
