with monthly_auto_premium_rates as (
    select
        branch_earnings_month,
        policy_period_start,
        policy_period_end,
        lower_bound,
        upper_bound,
        per_vehicle_rate,
        _es_update_timestamp
    from {{ ref('stg_analytics_claims__auto_insurance_rates_per_vehicle') }}
),

vehicle_counts_and_claims as (
    select
        date_month,
        market_id,
        avg_vehicle_count_rolling_12mo,
        claims_count_rolling_12mo,
        -- rolling 12 month claims per vehicle, nullif to avoid divide by zero
        claims_count_rolling_12mo / nullif(avg_vehicle_count_rolling_12mo, 0) as claims_per_vehicle_rolling_12mo
    from {{ ref('int_claims__historic_market_vehicle_claim_count') }}
),

market_premium_rate as (
    select
        vcc.market_id,
        vcc.avg_vehicle_count_rolling_12mo,
        vcc.claims_count_rolling_12mo,
        vcc.claims_per_vehicle_rolling_12mo,
        mp.per_vehicle_rate as insurance_rate_per_vehicle,
        -- convert the insurance rate per vehicle to a monthly charge and multiply by the avg vehicle count
        round((vcc.avg_vehicle_count_rolling_12mo * mp.per_vehicle_rate) / 12, 2) as monthly_premium_charge,
        vcc.date_month as branch_earnings_month,
        current_timestamp as modified_date
    from vehicle_counts_and_claims as vcc
        inner join monthly_auto_premium_rates as mp
            -- select the rates that fall within the policy period
            on (
                vcc.date_month > mp.policy_period_start
                and vcc.date_month <= mp.policy_period_end
            )
            -- select the bin that each market falls into
            and (
                vcc.claims_per_vehicle_rolling_12mo < mp.upper_bound
                and vcc.claims_per_vehicle_rolling_12mo >= mp.lower_bound
            )
)

select
    branch_earnings_month,
    market_id,
    avg_vehicle_count_rolling_12mo,
    claims_count_rolling_12mo,
    claims_per_vehicle_rolling_12mo,
    insurance_rate_per_vehicle,
    monthly_premium_charge
from market_premium_rate
