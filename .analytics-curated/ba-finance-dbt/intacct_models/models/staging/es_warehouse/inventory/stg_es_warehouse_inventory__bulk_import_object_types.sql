SELECT
    biot.bulk_import_object_type_id,
    biot.name,
    biot._es_update_timestamp
FROM {{ source('es_warehouse_inventory', 'bulk_import_object_types') }} as biot
