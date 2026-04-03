with source as (

    select * from {{ source('es_warehouse_public', 'line_item_deductions') }}

),

renamed as (

    select

        -- ids
        line_item_id,
        line_item_deduction_id,
        line_item_deduction_type_id,

        -- strings
        -- numerics
        amount,
        percentage,

        -- booleans
        -- dates
        date_created,
        date_updated,

        -- timestamps
        _es_update_timestamp,
        _es_load_timestamp

    from source

)

select * from renamed
