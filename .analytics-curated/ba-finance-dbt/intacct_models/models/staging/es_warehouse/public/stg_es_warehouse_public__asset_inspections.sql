SELECT
    ai.asset_inspection_id,
    ai.asset_id,
    ai.equipment_assignment_id,
    ai.completed,
    ai.completed_timestamp,
    ai.created,
    ai.completed_by_user_id,
    ai._es_update_timestamp
FROM {{ source('es_warehouse_public', 'asset_inspections') }} as ai
