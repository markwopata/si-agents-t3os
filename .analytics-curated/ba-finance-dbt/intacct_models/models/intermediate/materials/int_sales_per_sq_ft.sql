with revenue as (
    select
        date_trunc('month', datetime_created) as revenue_month,
        bt_branch_id,
        sum(total_amount) as total_revenue
    from {{ ref('int_revenue_cost') }}
    group by 1, 2
),

branch_sq_ft as (
    select
        bt_branch_id,
        market_name,
        square_footage
    from {{ ref('stg_analytics_gs__materials_branch') }}
)

select
    r.revenue_month,
    r.bt_branch_id,
    bsf.market_name,
    bsf.square_footage,
    r.total_revenue
from revenue as r
    left join branch_sq_ft as bsf
        on r.bt_branch_id = bsf.bt_branch_id
