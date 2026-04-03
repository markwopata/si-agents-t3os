with source as (

    select * from {{ source('analytics_tax', 'market_county') }}

),

renamed as (

    select

        -- id
        market_id,

        -- strings
        market_name,
        county,

        -- numerics
        latitude,
        longitude

    from source

)

select * from renamed
