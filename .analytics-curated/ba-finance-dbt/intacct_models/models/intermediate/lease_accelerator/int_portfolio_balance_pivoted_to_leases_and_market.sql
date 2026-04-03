with portfolio_trial_balance as (

    select * from {{ ref('stg_analytics_lease_accelerator__portfolio_balance_api_download') }}

)

, lease_market_calculations as (

    select
        schedule
        , market_id
        , starting_fiscal_period
        , sum(case when account_description like '%Lease asset%' then round(amount,2) else 0 end) as roua -- accounting for both operating finance leases
        , sum(case when account_description like '%Lease obligation%' or account_description like '%Purchase option liability%' then round(amount,2) else 0 end) as lease_liability -- accounting for both operating finance leases
        , sum(case when account_description like '%Accumulated depreciation%' then round(amount,2) else 0 end) as accumulated_depreciation -- accounting for both operating finance leases
    from portfolio_trial_balance
    group by 
        all

)

select * from lease_market_calculations
