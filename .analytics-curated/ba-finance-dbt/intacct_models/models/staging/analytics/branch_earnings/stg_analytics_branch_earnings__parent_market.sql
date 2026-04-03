with source as (
    select * from {{ source('analytics_branch_earnings', 'parent_market') }}
),

renamed as (
    select
        -- ids
        market_id,
        parent_market_id,

        -- dates
        start_date,
        end_date,
        date_trunc('month', start_date) as start_month,
        date_trunc('month', end_date)   as end_month
    from source
)

select * from renamed
