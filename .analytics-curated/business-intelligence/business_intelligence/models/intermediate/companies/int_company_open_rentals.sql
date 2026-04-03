select rm.customer_company_id as company_id, r.rental_id
from {{ ref('platform', 'dim_rentals') }} r 
-- join to get the start date
join {{ ref('platform', 'int_rentals_relationship_mapping') }} rm
ON rm.rental_id = r.rental_id
where 
    -- if a rentals with statuses as "Draft" or "Pending" in the 30 days
    (r.rental_status_id in (2,3) and rm.start_date::date >= DATEADD(day, -30, current_date()) )
    -- any rentals currently with status "On Rent"
    OR (r.rental_status_id = 5) 