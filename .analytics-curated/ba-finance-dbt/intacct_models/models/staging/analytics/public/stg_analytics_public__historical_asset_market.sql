with source as (

    select * from {{ source('analytics_public', 'historical_asset_market') }}

),

renamed as (

    select
        -- ids
        asset_id,
        market_id,

        -- timestamp
        date

    from source

)

select * from renamed
