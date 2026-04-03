with source as (
    select * from {{ source('es_warehouse_public', 'assets_aggregate') }}
),

renamed as (
    select

        -- ids 
        asset_id,
        company_id,
        equipment_make_id,
        equipment_model_id,
        equipment_class_id,
        category_id,
        asset_type_id,
        rental_branch_id,
        inventory_branch_id,
        service_branch_id,
        business_segment_id,

        -- strings
        custom_name,
        owner,
        make,
        model,
        class,
        category,
        year,
        serial_number,
        vin,
        asset_type,
        asset_class,

        -- booleans
        coalesce(
            custom_name ilike 'RR%' or serial_number ilike 'RR%'
            or company_id = 11606, -- Re-rent company
            false
        ) as is_rerent_asset,

        -- numerics
        oec,
        oec as original_equipment_cost,

        -- timetsamps
        date_created,
        purchase_date,
        first_rental as first_rental_date
    from source

)

select * from renamed
