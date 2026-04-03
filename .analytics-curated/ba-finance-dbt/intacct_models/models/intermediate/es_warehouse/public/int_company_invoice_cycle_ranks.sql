------------------------------------------------------------------------------
-- 1) Pull every approved invoice as its own billing cycle
------------------------------------------------------------------------------
with invoices_raw as (

  select
    i.invoice_id,
    i.order_id,
    i.company_id,
    i.billing_approved_date::date   as billing_approved_date,
    i.billed_amount
  from {{ ref('stg_es_warehouse_public__invoices') }} i
  where i.billing_approved_date is not null

),

------------------------------------------------------------------------------
-- 2) Number each invoice‐cycle per company in chronological order
------------------------------------------------------------------------------
invoice_cycles as (

  select
    invoice_id,
    order_id,
    company_id,
    billing_approved_date,
    billed_amount,
    row_number() over (
      partition by company_id
      order by billing_approved_date, invoice_id
    ) as invoice_sequence
  from invoices_raw

)

------------------------------------------------------------------------------
-- 3) Final output: each invoice = one commission invoice sequence
------------------------------------------------------------------------------
select
  invoice_id,
  order_id,
  company_id,
  billing_approved_date,
  billed_amount,
  invoice_sequence
from invoice_cycles
