
with source as (

    select * from {{ source('analytics_market_data', 'market_types') }}

),

renamed as (

    select
        market_type_id,
        name

    from source

)

select * from renamed
