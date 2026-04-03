with quotes as (
    select
        q.quote_pk_id,
        q.quote_id,
        q.invoice_id,
        q.payment_method,
        q.company_id,
        q.company_name,
        q.salesperson_user_id,
        q.secondary_salesperson_user_id,
        q.billing_provider,
        q.market_id,
        q.status,
        q.type_of_sale,
        q.quote_created_at,
        q.quote_completed_at,
        q.days_to_complete,
        q.is_current
    from {{ ref("stg_tools_trailer_retail_sales__quotes") }} as q
    where q.is_current
),

quote_details as (
    select
        quote_pk_id,
        quote_id,
        is_current,
        count(asset_pk_id) as asset_count,
        sum(total_asset_price) as total_price,
        sum(total_asset_cost) as total_cost,
        sum(total_rebate) as total_rebate,
        sum(total_margin) as total_margin
    from {{ ref("int_retail_sales_asset_detail") }}
    group by all
)

select
    q.*,
    qd.asset_count,
    qd.total_price,
    qd.total_cost,
    qd.total_rebate,
    qd.total_margin
from quotes as q
    left join quote_details as qd
        on q.quote_pk_id = qd.quote_pk_id
