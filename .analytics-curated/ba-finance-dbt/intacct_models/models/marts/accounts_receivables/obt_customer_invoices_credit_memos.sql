with fct_customer_invoices_credit_memos as (
    select * from {{ ref('fct_customer_invoices_credit_memos') }}
),

d_customer as (
    select * from {{ ref('dim_customer') }}
),

d_invoices as (
    select * from {{ ref('dim_ar_invoices') }}
),

d_credit_notes as (
    select * from {{ ref('dim_credit_notes') }}
)

select distinct
    c.customer_id,
    c.customer_name,
    i.invoice_date,
    i.invoice_number,
    c.do_not_rent_flag,
    cn.market_id,
    cn.invoice_number as credit_note_invoice_number,
    i.url_admin,
    cn.date_created as credit_note_creation_date,
    cn.url_credit_note_admin,
    cn.credit_note_number,
    cn.created_by,
    f.total_credit_amount,
    f.remaining_credit_amount,
    datediff('day', i.invoice_date, cn.date_created) as num_days_between_invoice_credit_date
from fct_customer_invoices_credit_memos as f
    inner join d_invoices as i
        on f.invoice_id = i.invoice_id
    inner join d_customer as c
        on f.customer_id = c.customer_id
    inner join d_credit_notes as cn
        on f.credit_note_id = cn.credit_note_id
