with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_asset_descs') }}

),

renamed as (

    select

        -- ids
        asset_code,
        serial_number,
        sage_transaction_number,

        -- strings
        admin_asset_id, -- drops characters after the special characters denoted and casts to number
        facility_type,
        last_modified_by,
        make,
        model,
        invoice_number,
        invoice_number_two,
        invoice_number_three,

        -- booleans
        _fivetran_deleted,
        _fivetran_synced

    from source
    where _fivetran_deleted != TRUE

)

select * from renamed
