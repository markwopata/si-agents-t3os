with customer as (
    select
        customer_id,
        customer_name,
        url_admin,
        market_id
    from {{ ref('stg_analytics_intacct__customer') }}
),

companies_info as (
    select
        company_id,
        do_not_rent_flag,
        owner_user_id
    from {{ ref('stg_es_warehouse_public__companies') }}
),

ar_customer_details as (
    select
        customer_id,
        max(date_paid) as last_customer_payment_date
    from {{ ref('ar_detail') }}
    group by
        1
),

users as (
    select
        user_id,
        full_name
    from {{ ref('stg_es_warehouse_public__users' ) }}
)

select
    c.customer_id,
    c.market_id,
    c.customer_name,
    c.url_admin,
    d.last_customer_payment_date,
    i.do_not_rent_flag,
    u.full_name as created_by_user
from customer as c
    left join ar_customer_details as d
        on c.customer_id = d.customer_id
    left join companies_info as i
        on d.customer_id::text = i.company_id::text
    left join users as u
        on i.owner_user_id = u.user_id
