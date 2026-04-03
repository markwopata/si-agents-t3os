------------------------------------------------------------------------------
-- 1) Pull every quote and its creator info
------------------------------------------------------------------------------
with quote_src as (
  select
    q.order_id,
    q.created_by           as created_by_user_id,
    q.quote_created_at
  from {{ ref('stg_quotes_quotes__quotes') }} q
  where q.order_id is not null
),

------------------------------------------------------------------------------
-- 2) Enrich creator with their latest directory title
------------------------------------------------------------------------------
creator_info AS (
  SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS full_name,
    cd.employee_title
  FROM {{ ref('stg_es_warehouse_public__users') }} u
  LEFT JOIN {{ ref('stg_analytics_payroll__company_directory') }} cd
    ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id
),

------------------------------------------------------------------------------
-- 3) Identify support‐created quotes
------------------------------------------------------------------------------
support_quotes as (
  select
    qs.order_id,
    qs.quote_created_at as support_created_date
  from quote_src qs
  join creator_info ci
    on qs.created_by_user_id = ci.user_id
  where ci.employee_title ilike '%customer support%'
)

------------------------------------------------------------------------------
-- 4) Final: only orders from support calls
------------------------------------------------------------------------------
select
  i.order_id,
  i.invoice_id,
  sq.support_created_date
from support_quotes sq
join {{ ref('stg_es_warehouse_public__invoices') }} i
  on i.order_id = sq.order_id
join {{ ref('stg_es_warehouse_public__orders') }} o 
   on i.order_id = o.order_id
where o.is_deleted = false
