with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_asset_descs') }}

),

renamed as (

    select

        -- ids
        ass_code as asset_code,
        ass_desc3 as serial_number,
        ass_desc12 as sage_transaction_number,

        -- strings
        coalesce(try_to_number(ass_desc2),try_to_number(regexp_replace(replace(ass_desc2, char(160), ''), '-.+$', ''))) as admin_asset_id, -- drops characters after the special characters denoted and casts to number ie raw_value: 121324-D -> after_regex: 121324
        ass_desc11 as facility_type,
        ass_user as last_modified_by,
        ass_desc4 as make,
        ass_desc5 as model,
        ass_desc6 as invoice_number,
        ass_desc7 as invoice_number_two,
        ass_desc9 as invoice_number_three,

        -- booleans
        _fivetran_deleted,
        _fivetran_synced

    from source

)

select * from renamed
