with source as (

    select * from {{ ref('base_analytics_asset4000_dbo__gl_asset') }}

)

, renamed as (

    select

        -- ids
        asset_code,

        -- strings
        asset_title,

        -- dates
        asset_purchase_date,
        asset_capitalized_date,

    from source

)

select * from renamed
