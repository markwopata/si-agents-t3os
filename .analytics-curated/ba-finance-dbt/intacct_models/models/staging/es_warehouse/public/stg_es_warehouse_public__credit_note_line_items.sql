with source as (

    select * from {{ source('es_warehouse_public', 'credit_note_line_items') }}

),

renamed as (

    select

        -- ids
        credit_note_line_item_id,
        credit_note_id,
        line_item_id,
        line_item_type_id,
        tax_rate_id,
        branch_id,

        -- strings
        description,
        extended_data,

        -- numerics
        tax_amount,
        credit_tax_rate_percentage,
        credit_tax_amount,
        tax_rate_percentage,
        round(credit_amount, 2) as credit_amount,
        credit_amount as credit_revenue,
        price_per_unit,
        number_of_units,
        override_market_tax_rate,
        amount,
        
        -- booleans
        taxable,

        -- timestamps
        date_updated,
        date_created,
        _es_update_timestamp

    from source

)

select * from renamed
