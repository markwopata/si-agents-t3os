select
    -- ids
    cd.employee_id::int as employee_id,
    cd.direct_manager_employee_id::int as direct_manager_employee_id,
    cd.market_id::int as market_id,
    m.company_id as market_company_id,
    cd.account_id,
    cd.greenhouse_application_id,

    -- strings
    m.company_name as market_company_name,
    cd.first_name,
    cd.last_name,
    cd.first_name || ' ' || cd.last_name as full_name,
    case
        -- There are a handful of nicknames that only have the first name (probably sourced/termed in UKG)
        when not contains(cd.nickname, cd.last_name)
            then cd.nickname || ' ' || cd.last_name
        else cd.nickname
    end as nickname,
    lower(trim(cd.work_email)) as work_email,
    lower(trim(cd.personal_email)) as personal_email,
    cd.employee_type,
    cd.employee_status,
    cd.employee_status in (
        'Active',
        'Apprentice (Fixed Term)',
        'External Payroll',
        'Leave with Pay',
        'Leave without Pay',
        'On Leave',
        'Work Comp Leave',
        'Seasonal (Fixed Term) (Seasonal)'
    ) as is_active_employee,
    trim(cd.employee_title) as employee_title,
    cd.worker_type,
    cd.location,
    cd.default_cost_centers_full_path,
    cd.direct_manager_name,
    {{ format_phone_number('work_phone') }} as work_phone,
    {{ format_phone_number('home_phone') }} as home_phone,
    cd.pay_calc as wage_type,
    cd.pay_calc,
    cd.ee_state as employee_state,
    cd.ee_state,
    cd.doc_uname,
    cd.tax_location,
    cd.labor_distribution_profile,

    -- booleans
    case
        when cd.on_leave = 1 then true
        when cd.on_leave = 0 then false
    end as is_on_leave,

    -- dates
    cd.date_hired::date as date_hired,
    cd.date_rehired::date as date_rehired,
    cd.date_terminated::date as date_terminated,
    cd.position_effective_date::date as position_effective_date,
    cd.last_updated_date::date as last_updated_date

from {{ source('analytics_payroll', 'company_directory') }} as cd
    left join {{ ref('int_markets') }} as m
        on cd.market_id = m.market_id
