with f_disputes_creation as (
    select * from {{ ref('fct_disputes_creation') }}
),

d_disputes as (
    select * from {{ ref('dim_disputes') }}
),

d_invoices as (
    select * from {{ ref('dim_ar_invoices') }}
),

d_customer as (
    select * from {{ ref('dim_customer') }}
)

select distinct
    d.dispute_id,
    d.dispute_date_creation,
    d.branch_id,
    d.dispute_category,
    f.days_to_resolve,
    f.invoice_amount,
    i.invoice_number,
    i.url_admin,
    i.invoice_date,
    c.customer_name,
    c.customer_id,
    c.last_customer_payment_date,
    c.do_not_rent_flag
from f_disputes_creation as f
    inner join d_disputes as d
        on f.dispute_id = d.dispute_id
    inner join d_invoices as i
        on f.invoice_id = i.invoice_id
    inner join d_customer as c
        on f.customer_id = c.customer_id
