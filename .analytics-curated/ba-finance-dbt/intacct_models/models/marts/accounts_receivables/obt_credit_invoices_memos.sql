with fct_invoice_amounts_past_due as (
    select * from {{ ref('fct_invoice_amounts_past_due') }}
),

d_customer as (
    select * from {{ ref('dim_customer') }}
),

d_customer_salespersons as (
    select * from {{ ref('dim_customer_salespersons') }}
)

select
    -- ids
    c.customer_id,
    c.market_id,
    -- strings
    c.customer_name,
    c.url_admin,
    c.created_by_user,
    s.list_of_salespersons,
    case
        when (f.customer_total_balance_owed - coalesce(f.credit_limit, 0)) > 0 then 'Over Credit Limit'
        else 'Under Credit Limit'
    end as customer_credit_category,

    -- booleans
    c.do_not_rent_flag,

    -- dates
    c.last_customer_payment_date,

    -- measures
    {{ dbt_utils.star(from=ref('fct_invoice_amounts_past_due'), relation_alias='f',  except = ['CUSTOMER_ID']) }}

from fct_invoice_amounts_past_due as f
    inner join d_customer as c
        on f.customer_id = c.customer_id
    left join d_customer_salespersons as s
        on c.customer_id::text = s.company_id::text
