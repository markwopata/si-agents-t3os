with source as (

    select * from {{ source('analytics_claims', 'auto_insurance_rates_per_vehicle') }}

),

renamed as (

    select

        -- numerics
        lower_bound,
        upper_bound,
        per_vehicle_rate,
        per_vehicle_rate / 12 as per_vehicle_rate_monthly,

        -- dates
        policy_period_start::date as policy_period_start,
        policy_period_end::date as policy_period_end,
        branch_earnings_month::date as branch_earnings_month,

        -- timestamps
        _es_update_timestamp


    from source

)

select
    policy_period_start,
    policy_period_end,
    lower_bound,
    upper_bound,
    per_vehicle_rate,
    per_vehicle_rate_monthly,
    branch_earnings_month,
    _es_update_timestamp
from renamed
