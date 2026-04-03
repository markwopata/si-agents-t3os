with monthly_premiums as (
    select
        branch_earnings_month,
        policy_period_start,
        policy_period_end,
        lower_bound,
        upper_bound,
        per_employee_rate,
        _es_update_timestamp
    from {{ ref('stg_analytics_claims__worker_comp_insurance_rates_per_employee') }}
),

employee_counts_and_claims as (
    select
        date_month,
        market_id,
        avg_headcount_rolling_12mo,
        claims_count_rolling_12mo,
        -- rolling 12 month claims per vehicle, nullif to avoid divide by zero
        claims_count_rolling_12mo / avg_headcount_rolling_12mo as claims_per_employee_rolling_12mo
    from {{ ref('int_claims__historic_market_employee_claim_count') }}
),

market_premium_rate as (
    select
        ecc.market_id,
        ecc.avg_headcount_rolling_12mo,
        ecc.claims_count_rolling_12mo,
        ecc.claims_per_employee_rolling_12mo,
        mp.per_employee_rate as insurance_rate_per_employee,
        round((avg_headcount_rolling_12mo * insurance_rate_per_employee / 12), 2) as monthly_premium_charge,
        ecc.date_month as branch_earnings_month,
        current_timestamp as modified_date
    from employee_counts_and_claims as ecc
        inner join monthly_premiums as mp
            -- select the rates that fall within the policy period
            on (
                ecc.date_month > mp.policy_period_start
                and ecc.date_month <= mp.policy_period_end
            )
            -- select the bin that each market falls into
            and (
                ecc.claims_per_employee_rolling_12mo < mp.upper_bound
                and ecc.claims_per_employee_rolling_12mo >= mp.lower_bound
            )
)

select
    branch_earnings_month,
    market_id,
    avg_headcount_rolling_12mo,
    claims_count_rolling_12mo,
    claims_per_employee_rolling_12mo,
    insurance_rate_per_employee,
    monthly_premium_charge,
    modified_date
from market_premium_rate
