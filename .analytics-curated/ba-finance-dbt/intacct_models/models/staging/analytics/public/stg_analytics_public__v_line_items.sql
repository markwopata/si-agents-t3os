with source as (

    select * from {{ source('analytics_public', 'v_line_items') }}

),

renamed as (

    select

        -- ids
        invoice_id,
        rental_id,
        line_item_id,
        line_item_type_id,
        branch_id,
        asset_id,
        part_id,
        tax_rate_id,
        credit_note_line_item_id,
        credit_note_id,

        -- strings
        line_item_type,
        description,
        extended_data,

        -- numerics
        invoice_no,
        number_of_units,
        price_per_unit,
        amount,
        override_market_tax_rate,
        payouts_processed,
        tax_rate_percentage,
        tax_amount,


        -- booleans
        taxable as is_taxable,

        -- dates
        gl_date_created,
        gl_billing_approved_date,
        date_updated,
        date_created,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
