SELECT
    decfo.equipment_class_key,
    decfo.equipment_class_id,
    decfo.equipment_class_name,
    decfo.equipment_class_description,
    decfo.business_segment_id,
    decfo.business_segment_name,
    decfo.equipment_class_category_id,
    decfo.sub_category_id,
    decfo.sub_category_name,
    decfo.parent_category_id,
    decfo.parent_category_name,
    decfo.is_equipment_class_rentable,
    decfo.is_equipment_class_ideal_current_quarter,
    decfo.is_equipment_class_ideal_previous_quarter,
    decfo.is_equipment_class_ideal_all_four_quarters
FROM {{ source('fleet_optimization_gold', 'dim_equipment_classes_fleet_opt') }} as decfo
