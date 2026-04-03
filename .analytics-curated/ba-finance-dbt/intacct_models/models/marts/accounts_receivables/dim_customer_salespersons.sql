with invoices as (
    select * from {{ ref('stg_es_warehouse_public__invoices') }}
),

companies as (
    select * from {{ ref('stg_es_warehouse_public__companies') }}
),

approved_invoice_salespersons as (
    select * from {{ ref('stg_es_warehouse_public__approved_invoice_salespersons') }}
),

users as (
    select * from {{ ref('stg_es_warehouse_public__users') }}
)

select
    i.company_id,
    c.customer_name,
    array_agg(distinct u.full_name) within group (order by u.full_name asc) as list_of_salespersons
from invoices as i
    inner join companies as c
        on i.company_id = c.company_id
    inner join approved_invoice_salespersons as s
        on i.invoice_id = s.invoice_id
    inner join users as u
        on s.salesperson_id = u.user_id
group by
    all
