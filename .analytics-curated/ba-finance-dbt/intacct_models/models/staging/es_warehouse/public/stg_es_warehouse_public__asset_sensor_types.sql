SELECT
    ast.asset_sensor_type_id,
    ast.name,
    ast.asset_sensor_type_canonical_id,
    ast.date_created,
    ast._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_sensor_types') }} as ast
