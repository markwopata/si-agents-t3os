with out as (
    select
        _es_update_timestamp::date as snapshot_date,
        date_trunc(month, _es_update_timestamp)::date as period_start_date,
        split_part(default_cost_centers_full_path, '/', '1') as division,
        split_part(default_cost_centers_full_path, '/', '2') as region,
        split_part(default_cost_centers_full_path, '/', '3') as district,
        split_part(default_cost_centers_full_path, '/', '4') as location, -- noqa: RF04
        split_part(default_cost_centers_full_path, '/', '5') as cost_center,
        market_id::int as market_id,
        employee_id::int as employee_id,
        employee_title,
        concat(first_name, ' ', last_name) as full_name,
        md5(concat(employee_id, snapshot_date)) as pk_headcount_id
    from {{ ref('stg_analytics_payroll__ee_company_directory_12_month') }}
    where employee_status in
        (
            'External Payroll', 'Active', 'Leave with Pay', 'Leave without Pay', 'Work Comp Leave', 'On Leave',
            'Seasonal (Fixed Term) (Seasonal)', 'Apprentice (Fixed Term)'
        )
        and employee_status != 'Contractor'
        and employee_title not ilike 'intern'
        and employee_title not ilike '%Intern %'
        and employee_title not ilike '%Intern:%'
        and employee_title not like '%Test%'
        and _es_update_timestamp >= '2022-12-01'
)

select *
from out
