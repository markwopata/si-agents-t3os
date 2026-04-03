-- combine here to classfiy companies as dormant, unconverted, inactive, active
select 
    c.company_id
    , case
        when cf.conversion_status = 'Not Converted' THEN 'Not Converted'
        when cf.conversion_status = 'Pending' OR (r.company_id IS NOT NULL or q.company_id IS NOT NULL) THEN 'Pending'  
        when inv.days_since_invoice >= 120 then 'Dormant'
        when inv.days_since_invoice >= 90 AND inv.days_since_invoice < 120 then 'Inactive'
        ELSE 'Active'
    end as company_activity_status

from {{ ref('platform', 'dim_companies') }} c 
left join (
        select distinct company_id 
        from {{ ref('int_company_open_rentals') }} 
    ) r 
    on r.company_id = c.company_id
left join (
        select distinct company_id 
        from {{ ref('int_company_open_quotes') }} 
    ) q
    on q.company_id = c.company_id
left join {{ ref('int_company_last_invoice') }} inv
    on c.company_id = inv.company_id 
left join {{ ref('int_company_conversion_flags') }} cf
    on c.company_id = cf.company_id
where c.company_id <> -1