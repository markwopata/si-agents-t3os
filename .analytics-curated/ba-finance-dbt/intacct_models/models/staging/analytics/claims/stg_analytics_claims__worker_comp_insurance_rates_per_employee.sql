with base as (

    select * from {{ ref('base_analytics_claims__worker_comp_insurance_rates_per_employee') }}

)
select

    -- dates
    policy_period_start,
    policy_period_end,
    branch_earnings_month,

    -- numerics
    lower_bound,
    upper_bound,
    per_employee_rate,
    per_employee_rate_monthly,

    -- timestamps
    _es_update_timestamp


from base
qualify rank() over (
        partition by policy_period_start
        order by _es_update_timestamp desc
    ) = 1
