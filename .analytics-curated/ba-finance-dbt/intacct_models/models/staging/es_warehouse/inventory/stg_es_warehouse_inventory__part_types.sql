with source as (
    select * from {{ source('es_warehouse_inventory', 'part_types') }}
)

, renamed as (
    select
        -- ids
        part_type_id,
        part_category_id,
        company_id,

        -- strings
        description,
        image_url,
    
        class_number,
        -- booleans
        verified_for_company,
        verified_globally,

        -- timestamps
        date_created,
        date_updated,
        _es_update_timestamp
    from source
)
select * from renamed
