with profit_sharing_projections as (
-- Sum up profit sharing accrual projections by market/month
    select
        market_id,
        gl_month,
        account_no,
        account_name,
        sum(projected_profit_sharing_accrual + projected_revenue_sharing_accrual) as month_end_projected_amount
    from {{ ref('int_account_targets_current_month_profit_sharing_projections') }}
    group by all
),

live_targets_projections as (
-- Join payroll data onto the rest of the live targets and projections
    select
        np.market_id,
        np.gl_month,
        np.account_no,
        np.account_name,
        np.rev_exp,
        np.account_category,
        np.cost_type,
        np.actual_amount,
        np.comp_metric,
        np.comp_metric_amount,
        coalesce(pp.month_end_projected_amount + coalesce(psp.month_end_projected_amount, 0), np.month_end_projected_amount) as month_end_projected_amount,
        np.month_end_projected_comp_metric_amount
    from {{ ref('int_account_targets_current_month_non_payroll_projections') }} as np
        left join {{ ref('int_account_targets_current_month_payroll_projections') }} as pp
            on np.market_id = pp.market_id
                and np.gl_month = pp.gl_month
                and np.account_no = pp.account_no
                and np.account_name = pp.account_name
        left join profit_sharing_projections as psp
            on np.market_id = psp.market_id
                and np.gl_month = psp.gl_month
                and np.account_no = psp.account_no
                and np.account_name = psp.account_name
),

combined_actuals as (
    select
        market_id,
        gl_month,
        account_no,
        account_name,
        rev_exp,
        account_category,
        cost_type,
        actual_amount,
        comp_metric,
        comp_metric_amount,
        null as month_end_projected_amount,
        null as month_end_projected_comp_metric_amount
    from {{ ref('int_account_targets_actuals_static') }}

    union all

    select *
    from live_targets_projections
)

select
    m.region as region_id,
    m.region_name as region,
    m.district,
    ca.market_id,
    m.market_name,
    m.market_type,
    ca.gl_month,
    (case
        when pp.period_published is not null then 'Static'
        else 'Trending'
    end) as month_status,
    ca.account_no,
    ca.account_name,
    ca.rev_exp,
    ca.account_category,
    ca.cost_type,
    ca.actual_amount,
    ca.comp_metric,
    ca.comp_metric_amount,
    ca.month_end_projected_amount,
    ca.month_end_projected_comp_metric_amount,
    cmt.account_target as account_target_pct
from combined_actuals as ca
    inner join {{ ref('market') }} as m
        on ca.market_id = m.child_market_id
    inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
        on ca.gl_month = pp.trunc::date
    inner join {{ ref('seed_account_targets_market_comp_map') }} as mcm
        on ca.market_id = mcm.market_id
    left join {{ ref('int_account_targets_comp_market_targets') }} as cmt
        on mcm.comp_markets_id = cmt.comp_markets_id
            and ca.account_no = cmt.account_no
            and ca.account_name = cmt.account_name
