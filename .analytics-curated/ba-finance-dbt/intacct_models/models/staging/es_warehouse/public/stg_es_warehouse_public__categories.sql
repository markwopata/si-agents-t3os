with source as (

    select * from {{ source('es_warehouse_public', 'categories') }}

),

renamed as (

    select

        -- ids

        category_id,
        parent_category_id,
        company_division_id,
        company_id,

        -- strings
        name,
        canonical_name,
        layout_script,
        image,
        description,
        singular_name,

        -- booleans
        active as is_active,

        -- numerics
        sort_index,

        -- timestamp
        _es_update_timestamp,
        date_deactivated

    from source

)

select * from renamed
