with rental_reqs as (
  select
    rr.request_id,
    rr.quote_id,
    rr.request_created_at   as request_date,
    rr.branch_id,
    rr.web_user_id
  from {{ ref('stg_rental_order_request_public__rental_requests') }} rr
  where rr.quote_id is not null
), 

rental_quotes as (
  select
    null                           as request_id,
    q.quote_created_at             as request_date,
    q.quote_id,
    q.order_id                     as quote_order_id,
    q.quote_created_at,
    q.branch_id,
    null                           as web_user_id
  from {{ ref('stg_quotes_quotes__quotes') }} q
  join {{ ref('stg_quotes_quotes__request_source') }} rs
    on q.request_source_id = rs.request_source_id
  where rs.name = 'RETAIL'
),


req_to_quote AS (
  select
    rr.request_id,
    rr.request_date,
    rr.quote_id,
    q.order_id       as quote_order_id,
    q.quote_created_at,
    q.branch_id,
    rr.web_user_id
  from rental_reqs rr
  join {{ ref('stg_quotes_quotes__quotes') }} q
    on q.quote_id = rr.quote_id
  -- don’t pull in any “RETAIL” quotes here
  join {{ ref('stg_quotes_quotes__request_source') }} rs
    on q.request_source_id = rs.request_source_id
  where rs.name != 'RETAIL'
),

combined_quotes as (
  select * from req_to_quote
  union all
  select * from rental_quotes
),

quote_to_order as (
  select
    cq.request_id,
    i.company_id,
    cq.request_date,
    cq.quote_id,
    cq.quote_order_id             as order_id,
    i.invoice_id,
    o.date_created                as order_date,
    cq.branch_id,
    cq.web_user_id
  from combined_quotes cq
  join {{ ref('stg_es_warehouse_public__invoices') }} i
    on i.order_id = cq.quote_order_id
  join {{ ref('stg_es_warehouse_public__orders') }} o
    on i.order_id = o.order_id
)

select
  request_id,
  company_id,
  quote_id,
  order_id,
  invoice_id,
  request_date,
  order_date,
  branch_id,
  web_user_id
from quote_to_order
