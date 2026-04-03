with source as (
    select * from {{ source('es_warehouse_inventory', 'parts') }}
)

, renamed as (

    select
        -- ids
        cast(part_id as string) as part_id,
        part_type_id,
        provider_part_number_id,
        company_id,
        duplicate_of_id,
        provider_id,
        item_id,
        product_type_id,
        manufacturer_id,
        manufacturer_family_id,
        product_category_id,
        product_class_id,
        conversion_unit_id,

        -- strings
        name as description,
        part_number,
        verified,
        sku_field,
        search,
        manufacturer_number,
        model,
        upc,
        -- booleans
        verified_for_company,
        verified_globally,
        is_global,

        -- numerics
        msrp,
        year,

        -- timestamps
        date_created,
        date_updated,
        date_archived,
        _es_update_timestamp
    
    from source

)

select * from renamed
