-- quotes where status is open and the company is already in our system
select q.quote_id, qc.company_id, qc.quote_customer_id
from {{ ref('int_quotes') }} q
join {{ ref('int_quote_customers') }} qc
    ON COALESCE(q.quote_customer_id, 'Unknown') = COALESCE(qc.quote_customer_id, 'Unknown')
where q.quote_status = 'Open' 
and qc.company_id IS NOT NULL