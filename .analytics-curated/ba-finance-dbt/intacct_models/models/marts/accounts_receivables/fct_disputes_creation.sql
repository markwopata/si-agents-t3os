with disputes as (
    select
        dispute_id,
        invoice_id,
        date_created
    from {{ ref('stg_es_warehouse_public__disputes') }}
),

dispute_measures as (
    select
        dispute_id,
        days_to_resolve
    from {{ ref('stg_analytics_treasury__dispute_summary') }}
),

invoice_number_amount as (
    select
        customer_id,
        invoice_id,
        invoice_number,
        invoice_amount
    from {{ ref('fct_invoice_number_amount') }}
)

select
    d.dispute_id,
    i.customer_id,
    i.invoice_id,
    m.days_to_resolve,
    i.invoice_amount
from disputes as d
    inner join dispute_measures as m
        on d.dispute_id = m.dispute_id
    inner join invoice_number_amount as i
        on d.invoice_id = i.invoice_id
