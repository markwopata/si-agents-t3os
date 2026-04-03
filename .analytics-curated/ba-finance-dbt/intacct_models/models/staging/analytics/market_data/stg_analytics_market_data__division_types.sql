with source as (

    select * from {{ source('analytics_market_data', 'division_types') }}

),

renamed as (

    select
        division_id,
        name as division_name

    from source

)

select * from renamed
