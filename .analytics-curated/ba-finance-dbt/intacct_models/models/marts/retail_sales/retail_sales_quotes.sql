select
    q.*,
    u.full_name as salesperson_name,
    u.email_address as salesperson_email,
    u2.full_name as secondary_salesperson_name,
    u2.email_address as secondary_salesperson_email,
    m.child_market_name as market_name,
    m.market_id as parent_market_id,
    m.market_name as parent_market_name
from {{ ref("int_retail_sales_quote_detail") }} as q
    left join {{ ref("stg_es_warehouse_public__users") }} as u
        on q.salesperson_user_id = u.user_id
    left join {{ ref("stg_es_warehouse_public__users") }} as u2
        on q.secondary_salesperson_user_id = u2.user_id
    left join {{ ref("market") }} as m
        on q.market_id = m.child_market_id
where q.is_current
