with quotes as (
    select *
    from {{ ref("stg_analytics_retail_sales__retail_sales_quotes") }}
)

select
    invoice_id,
    array_agg(quote_id) as quote_id,
    sum(total_price) as total_revenue,
    sum(total_cost) as total_cost,
    sum(total_rebate) as total_rebate,
    sum(total_margin) as total_profit,
    div0(total_profit, total_revenue) as profit_margin
from quotes
where status = 'complete'
    and invoice_id is not null
group by invoice_id
