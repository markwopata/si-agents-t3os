with source as (

    select * from {{ source('es_warehouse_public', 'line_item_deduction_types') }}

),

renamed as (

    select

        -- ids
        line_item_deduction_type_id,

        -- strings
        name,
        deduction_method,


        -- numerics
        -- booleans
        is_after_tax,

        -- dates
        -- timestamps
        _es_update_timestamp,
        _es_load_timestamp,

    from source

)

select * from renamed
