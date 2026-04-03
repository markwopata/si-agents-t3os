{# health_insurance_per_person = float(656.72)  # Per-person health insurance allocation amount. This number is an estimate
# coming from Mark + Mitch Ritter. Jan-23: after an analysis with Mitch we determined we were probably a little
# conservative on the 2022 PEPM numbers, and given his expectations for 2023 we are going to hold the PEPM charge to the
# branches for health insurance at 656.72 PEPM applied to all employees at the branch. Note: we got some improvement
# from 22 to 23 from switching to Anthem. Reassess either in the middle of the year or 2024 start. #}


with employees as (
    select
        employee_id,
        date_trunc(month, _es_update_timestamp) as gl_date,
        market_id,
        employee_status,
        employee_title
    from {{ ref('stg_analytics_payroll__company_directory_vault') }}
    where gl_date between '{{ live_be_start_date() }}' and '{{ live_be_end_date() }}'
    qualify
        row_number() over (partition by employee_id, gl_date order by _es_update_timestamp desc) = 1
),

employee_count as (
    select
        market.market_id,
        gl_date::date as gl_date,
        market.market_id::varchar as document_number,
        count(employee_id) as number_of_employees,
        round(count(employee_id) * -749.93, 2) as amount
    from employees
        left join {{ ref("market") }} as market
            on employees.market_id = market.child_market_id
    where market.region_name is not null
        and employee_status not in ('Terminated', 'Never Started', 'Not In Payroll', 'Inactive')
        and employee_title not ilike '%telematic%'
    group by 1, 2, 3
)

select
    market_id,
    'HFAB' as account_number,
    'Market ID | GL Date' as transaction_number_format,
    market_id || '|' || gl_date::varchar as transaction_number,
    'Health Insurance '
    || gl_date::varchar
    || ' - '
    || number_of_employees::varchar
    || ' active employees' as description,
    gl_date,
    'Market' as document_type,
    document_number,
    null as url_sage,
    null as url_concur,
    null as url_admin,
    null as url_t3,
    amount,
    object_construct(
        'number_of_employees', number_of_employees
    ) as additional_data,
    'ANALYTICS' as source,
    'Health Insurance' as load_section,
    '{{ this.name }}' as source_model
from employee_count
