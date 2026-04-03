with source as (

    select * from {{ source('es_warehouse_public', 'equipment_classes') }}

),

renamed as (

    select

        -- ids
        equipment_class_id,
        category_id,
        primary_photo_id,
        company_division_id,
        maintenance_group_id,
        company_id,
        business_segment_id,

        -- strings
        metric_name,
        name,
        description,

        -- booleans
        deleted as is_deleted,
        weekly_minimum as is_weekly_minimum,
        rentable as is_rentable,

        -- dates
        date_deleted,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated

    from source

)

select * from renamed
