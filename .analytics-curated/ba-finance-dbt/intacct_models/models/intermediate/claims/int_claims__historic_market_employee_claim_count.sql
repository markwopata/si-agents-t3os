with monthly_employees as (
    -- selecting employee counts by the end of month per branch
    select
        cdv.market_id,
        m.market_name,
        cdv.employee_id,
        cdv.employee_status,
        cdv.date_hired,
        cdv.date_rehired,
        cdv._es_update_timestamp
    from {{ ref('stg_analytics_payroll__company_directory_vault') }} cdv
        left join {{ ref('int_markets') }} as m
        on cdv.market_id = m.market_id
    -- excluding employee types that don't count towards worker's comp
    where employee_status not in (
            'Terminated', 'Never Started', 'Not In Payroll', 'Inactive', 'External Payroll',
            'Military Intern'
        )
    -- counting employees by market based on their location at the end of the month
    qualify row_number()
            over (
                partition by cdv.employee_id, date_trunc('month', cdv._es_update_timestamp)
                order by cdv._es_update_timestamp desc
            )
        = 1
),


employee_counts as (
    select
        date_trunc('month', _es_update_timestamp)::date as date,
        market_id,
        market_name,
        count(employee_id) as emp_count
    from monthly_employees
    --removes employees who are listed as active before their start date
    where coalesce(date_rehired::date, date_hired::date) <= _es_update_timestamp::date
        -- data before this date is not reliable
        and date_trunc('month', _es_update_timestamp)::date >= date('2022-10-01')
    group by 1, 2, 3
),

claims_count as (
    select
        date_trunc('month', date_of_injury::date) as date,
        market_id,
        --count all the LT claims for each month
        count(claim_number) as claims_count
    from {{ ref('int_claims__work_comp_insurance_claims') }}
    where wc_claim_type = 'LT'
    group by 1, 2
),

rolling_functions as (
    select
        ec.date,
        ec.market_id,
        ec.market_name,
        -- employee headcount for the month
        ec.emp_count,
        -- number of claims for the month
        cc.claims_count,
        --rolling average of the employee count for the last 12 months 
        avg(ec.emp_count)
            over (
                partition by ec.market_id
                order by ec.date
                rows between 11 preceding and current row
            ) as avg_headcount_rolling_12mo,
        --sum the claim count for the last 12 months        
        sum(coalesce(claims_count, 0)) over (
            partition by ec.market_id
            order by ec.date rows between 11 preceding and current row
        ) as claims_count_rolling_12mo
    from employee_counts as ec
        left join claims_count as cc
            on ec.date = cc.date and ec.market_id = cc.market_id
    order by ec.date, ec.market_id
)

select
    date as date_month,
    market_id,
    market_name,
    round(avg_headcount_rolling_12mo, 0) as avg_headcount_rolling_12mo,
    emp_count as monthly_employee_count,
    claims_count_rolling_12mo,
    coalesce(claims_count, 0) as monthly_claims_count
from rolling_functions as rf