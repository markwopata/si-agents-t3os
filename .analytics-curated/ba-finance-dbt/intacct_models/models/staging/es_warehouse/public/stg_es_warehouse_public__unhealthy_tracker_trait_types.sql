SELECT
    uttt.unhealthy_tracker_trait_type_id,
    uttt.name,
    uttt._es_update_timestamp
FROM {{ source('es_warehouse_public', 'unhealthy_tracker_trait_types') }} as uttt
