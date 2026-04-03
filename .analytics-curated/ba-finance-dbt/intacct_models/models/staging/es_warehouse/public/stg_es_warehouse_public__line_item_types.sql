with source as (

    select * from {{ source('es_warehouse_public', 'line_item_types') }} 


)


, renamed as (

    select
        -- ids
        line_item_type_id,
        tax_code_id,

        -- strings
        invoice_display_name,
        name as line_item_type_name, 

        -- numerics
        fixed_amount,

        -- booleans
        active,
        stackable

        -- timestamps
        _es_update_timestamp
    from source

)

select * from renamed
