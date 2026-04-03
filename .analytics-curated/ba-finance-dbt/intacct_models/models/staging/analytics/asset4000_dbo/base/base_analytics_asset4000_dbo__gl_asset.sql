with source as (

    select * from {{ source('analytics_asset4000_dbo', 'gl_asset') }}

)

, renamed as (

    select

        -- ids
        ass_code as asset_code,

        -- strings
        ass_title as asset_title,

        -- dates
        ass_pch_date as asset_purchase_date,
        ass_cap_date as asset_capitalized_date,

    from source

)

select * from renamed
