{{ config(
    materialized='incremental',
    unique_key=['equipment_class_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH 
    equipment_classes AS (

        select 
            equipment_class_id
            , equipment_class_name
            , equipment_class_description
            , is_rentable
            , category_id
            , category_name
            , parent_category_name
            , grandparent_category_name
            , category_is_active
            , category_description
            , company_id
            , company_division_id
            , company_division_name
            , is_deleted
            , business_segment_id
            , business_segment_name

        FROM {{ ref('int_equipment_classes')}} 

        {% if is_incremental() -%}
        WHERE ({{ filter_incremental_with_buffer_day('date_updated', buffer_days=1) }})
        {%- endif -%}
    ),

    cte_full_list AS (

        {% if not is_incremental() -%}
        SELECT 
            -1 AS equipment_class_id
            , 'Unknown Equipment Class Name' AS equipment_class_name
            , 'Unknown Equipment Class Description' AS equipment_class_description
            , FALSE AS is_rentable
            , FALSE as is_deleted
            , -1 AS category_id
            , 'Unknown Category Name' AS category_name
            , 'Unknown Parent Category Name' AS parent_category_name
            , 'Unknown Grandparent Category Name' AS grandparent_category_name
            , FALSE AS category_is_active
            , 'Unknown Category Description' AS category_description
            , -1 AS company_id
            , -1 AS company_division_id
            , 'Unknown Company Division Name' AS company_division_name
            , -1 as business_segment_id
            , 'Unknown Business Segment Name' AS business_segment_name

        UNION ALL
        {%- endif %}

        SELECT
            equipment_class_id
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
            , business_segment_id
            , business_segment_name

        FROM equipment_classes

    )
    

SELECT  
    {{ dbt_utils.generate_surrogate_key([
        'equipment_class_id', 'category_id', 'business_segment_id']) 
        }} AS equipment_class_key
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
    
    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM    cte_full_list