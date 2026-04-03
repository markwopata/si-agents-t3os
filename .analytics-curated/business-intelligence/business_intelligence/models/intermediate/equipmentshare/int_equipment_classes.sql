WITH

    equipment_classes as (
        select
            equipment_class_id
            , name
            , description
            , weekly_minimum -- doesn't seem to be used for anything
            , category_id
            , company_id
            , company_division_id
            , date_created
            , date_updated
            , date_deleted
            , deleted as is_deleted
            , rentable as is_rentable
            , business_segment_id

        from {{ ref('platform', 'equipment_classes') }}

        WHERE _equipment_classes_effective_delete_utc_datetime IS NULL
    ),

    -- flatten parent-child category relationship
    categories AS (
        SELECT
            category_id,
            category_name,
            parent_category_id,
            parent_category_name,
            grandparent_category_id,
            grandparent_category_name,
            is_active as category_is_active,
            category_description,
            date_deactivated

        FROM {{ ref('int_equipment_categories') }}
    ),

    business_segments as (

        select business_segment_id, name
        from {{ ref('platform', 'business_segments') }}

        where _business_segments_effective_delete_utc_datetime IS NULL
    ),
    
    company_divisions as (
        select 
            company_id
            , company_division_id
            , name as company_division_name
        from {{ ref('platform', 'es_warehouse__public__company_divisions') }}

    )

    select 
        eq.equipment_class_id
        , eq.name AS equipment_class_name
        , eq.description AS equipment_class_description
        , eq.is_rentable
        , eq.date_created
        , eq.date_updated
        , eq.is_deleted
        , eq.date_deleted
        , eq.category_id
        , c.category_name
        , c.parent_category_id
        , c.parent_category_name
        , c.grandparent_category_id
        , c.grandparent_category_name
        , c.category_is_active
        , c.category_description
        , eq.company_id
        , eq.company_division_id
        , cd.company_division_name
        , eq.business_segment_id
        , bs.name as business_segment_name

    from equipment_classes eq
    join categories c 
    on eq.category_id = c.category_id
    
    LEFT JOIN business_segments bs 
    on bs.business_segment_id = eq.business_segment_id
    LEFT JOIN company_divisions cd 
    on cd.company_id = eq.company_id and cd.company_division_id = eq.company_division_id