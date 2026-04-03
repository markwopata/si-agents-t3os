with stock_valuation as (
    select
        bt_branch_id,
        product_id,
        valuation_date,
        sum(stock_valuation) as stock_valuation
    from {{ ref('stg_analytics_bt_dbo__stock_valuation_data') }}
    group by
        bt_branch_id,
        product_id,
        valuation_date
),

cost as (
    select
        to_date(date_trunc('month', datetime_created)) as cost_month,
        bt_branch_id,
        product_id,
        sum(total_cost) as total_cost
    from {{ ref('int_revenue_cost') }}
    group by
        to_date(date_trunc('month', datetime_created)),
        bt_branch_id,
        product_id
),

ranked as (
    select
        sv.bt_branch_id,
        sv.product_id,
        to_date(date_trunc('month', sv.valuation_date)) as month_start,
        p.product_group_id,
        p.level_1_id,
        p.level_1_name,
        p.level_2_id,
        p.level_2_name,
        first_value(sv.stock_valuation) over (
            partition by sv.bt_branch_id, sv.product_id, to_date(date_trunc('month', sv.valuation_date))
            order by sv.valuation_date asc
        ) as start_value,
        last_value(sv.stock_valuation) over (
            partition by sv.bt_branch_id, sv.product_id, to_date(date_trunc('month', sv.valuation_date))
            order by sv.valuation_date asc
            rows between unbounded preceding and unbounded following
        ) as end_value
    from stock_valuation as sv
        inner join {{ ref('int_products') }} as p
            on sv.product_id = p.pk_product_id
    qualify row_number() 
            over (partition by sv.bt_branch_id, sv.product_id, to_date(date_trunc('month', sv.valuation_date))
                order by sv.valuation_date desc) = 1
)

select
    c.bt_branch_id,
    r.month_start,
    r.product_id,
    r.product_group_id,
    r.level_1_id,
    r.level_1_name,
    r.level_2_id,
    r.level_2_name,
    r.start_value,
    r.end_value,
    (r.start_value + r.end_value) / 2 as avg_value,
    sum(c.total_cost) as total_cost
from cost as c
    inner join ranked as r
        on c.bt_branch_id = r.bt_branch_id
            and c.product_id = r.product_id
            and c.cost_month = r.month_start
group by
    c.bt_branch_id,
    r.month_start,
    r.product_id,
    r.product_group_id,
    r.level_1_id,
    r.level_1_name,
    r.level_2_id,
    r.level_2_name,
    r.start_value,
    r.end_value
