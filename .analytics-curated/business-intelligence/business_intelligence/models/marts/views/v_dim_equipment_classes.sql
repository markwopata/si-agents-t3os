SELECT  
    equipment_class_key
    , equipment_class_id
    , equipment_class_name
    , equipment_class_description
    , is_rentable
    , is_deleted
    , category_id
    , category_name
    , parent_category_name
    , grandparent_category_name
    , category_is_active
    , category_description
    , company_id
    , company_division_id
    , company_division_name
    , business_segment_name

    , _created_recordtimestamp
    , _updated_recordtimestamp

FROM  {{ ref('dim_equipment_classes') }}