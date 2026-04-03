with source as (

    select * from {{ source('analytics_public', 'market_goals') }}

),

renamed as (

    select

        -- ids
        market_id::integer as market_id,

        -- strings
        name::varchar as name,
        market_level::varchar as market_level,

        -- numerics
        revenue_goals::numeric as revenue_goals,

        -- date
        start_date::date as start_date,
        end_date::date as end_date,

        -- timestamps
        months::timestamp as months,
        market_start_date::timestamp as market_start_date


    from source

)

select * from renamed
