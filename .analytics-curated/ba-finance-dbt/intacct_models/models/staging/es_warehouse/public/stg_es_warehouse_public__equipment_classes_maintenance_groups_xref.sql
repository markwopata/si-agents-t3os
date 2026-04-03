SELECT
    ecmgx.equipment_classes_maintenance_groups_xref_id,
    ecmgx.equipment_class_id,
    ecmgx.maintenance_group_id,
    ecmgx.date_deleted,
    ecmgx._es_update_timestamp
FROM {{ source('es_warehouse_public', 'equipment_classes_maintenance_groups_xref') }} as ecmgx
