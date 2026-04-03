with next_two_months as (
    -- returns the 2 months after the last published branch earnings date
    -- ie '2025-03-01' and '2025-04-01'

    select dateadd('month', 1, '{{ last_branch_earnings_published_date() }}'::date) as return_date

    union all

    select dateadd('month', 2, '{{ last_branch_earnings_published_date() }}'::date) as return_date

)


, employees as (

    select 
        cdv.employee_id, 
        cdv.market_id, 
        cdv.employee_status, 
        cdv.employee_title,
        cdv._es_update_timestamp
    from {{ ref('stg_analytics_payroll__company_directory_vault')}} cdv
    where date_trunc('month', _es_update_timestamp) in (select * from next_two_months)
    qualify row_number() over (partition by employee_id order by _es_update_timestamp desc) = 1

)

select
    e.market_id::text as mkt_id,
    mrx.market_name as mkt_name,
    'HFAB' as acctno,
    concat('Health Insurance ', to_char(to_date('2025-03-01'), 'MON YYYY'),' - ', count(e.employee_id)::varchar, ' active employees') as descr,
    last_day(to_date('2025-03-01')) as gl_date,
    '7' as doc_no,
    concat(e.market_id::text, '-', 'HFAB', '-', '7') as pk,
    round(count(e.employee_id) * -749.93, 2) as amt
    /* 
    
        - 749.93 is the estimated per-person health insurance allocation amount coming from Mark + Mitch Ritter
        - June 2024 - Health Insurance was assessed and deemed to be close enough to not be worth changing
        - January 2025: after an analysis with Mitch we determined we were probably a little conservative on the 2024 PEPM numbers, and given his expectations for 2023 we are going to hold the PEPM charge to the branches for health insurance at 749.93 PEPM applied to all employees at the branch.
          Note: we got some improvement from 22 to 23 from switching to Anthem. Reassess either in the middle of the year or 2024 start.

    */
from employees e
inner join {{ ref('market_region_xwalk') }} mrx
    on e.market_id = mrx.market_id
where 
    e.employee_status not in ('Terminated', 'Never Started', 'Not In Payroll', 'Inactive')
    and e.employee_title not ilike '%telematic%'
    and mrx.region is not null
group by e.market_id::text, mrx.market_name
