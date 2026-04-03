
with source as (

    select * from {{ source('analytics_market_data', 'market_data') }}

)

, renamed as (
    select
        -- ids
        market_data_id
        , market_id
        , district_id
        , market_type_id
        , division_id
        
        -- booleans
        , active as is_active_market
        , is_dealership

    from source
)

select * from renamed