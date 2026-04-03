SELECT
    fsm.equipment_class_id,
    fsm.class,
    fsm.category_id,
    fsm.category,
    fsm.mix_group
FROM {{ source('analytics_public', 'fleet_specialty_mix') }} as fsm
where fsm.equipment_class_id is not null
