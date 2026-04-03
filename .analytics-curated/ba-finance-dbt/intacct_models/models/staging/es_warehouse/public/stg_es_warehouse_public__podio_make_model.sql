SELECT
    pmm.category_id,
    pmm.cat_name,
    pmm.subcat_id,
    pmm.subcat_name,
    pmm.equipment_class_id,
    pmm.class_name,
    pmm.equipment_make_id,
    pmm.make,
    pmm.equipment_model_id,
    pmm.model
FROM {{ source('es_warehouse_public', 'podio_make_model') }} as pmm
