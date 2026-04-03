with source as (
      select * from {{ source('analytics_rate_achievement', 'fuel_rates') }}
),
renamed as (
    select
    -- ids
        state_id,
        fuel_type_id,
        rate_type_id,

    -- timestamps
        start_date,
        end_date,

    -- strings
        state,
        state_abbreviation,

    -- numerics
        price_per_gallon

    from source
)
select * from renamed
  