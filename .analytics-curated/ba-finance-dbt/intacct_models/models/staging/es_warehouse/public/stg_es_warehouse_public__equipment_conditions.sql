SELECT
    ec.equipment_condition_id,
    ec.name,
    ec.description,
    ec._es_update_timestamp
FROM {{ source('es_warehouse_public', 'equipment_conditions') }} as ec
