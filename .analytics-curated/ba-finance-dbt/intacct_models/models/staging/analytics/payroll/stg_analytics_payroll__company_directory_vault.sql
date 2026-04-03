with source as (

    select * from {{ source('analytics_payroll', 'company_directory_vault') }}

),

renamed as (

    select

        -- ids
        employee_id::int as employee_id,
        direct_manager_employee_id::int as direct_manager_employee_id,
        market_id::int as market_id,
        account_id,
        greenhouse_application_id,

        -- strings
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        case
            -- There are a handful of nicknames that only have the first name (probably sourced/termed in UKG)
            when not contains(nickname, last_name)
                then nickname || ' ' || last_name
            else nickname
        end as nickname,
        lower(trim(work_email)) as work_email,
        employee_type,
        employee_status,
        employee_status in (
            'Active',
            'Apprentice (Fixed Term)',
            'External Payroll',
            'Leave with Pay',
            'Leave without Pay',
            'On Leave',
            'Work Comp Leave',
            'Seasonal (Fixed Term) (Seasonal)'
        ) as is_active_employee,
        trim(employee_title) as employee_title,
        worker_type,
        location,
        default_cost_centers_full_path,
        direct_manager_name,
        {{ format_phone_number('work_phone') }} as work_phone,
        {{ format_phone_number('home_phone') }} as home_phone,
        lower(trim(personal_email)) as personal_email,
        pay_calc as wage_type,
        pay_calc,
        ee_state as employee_state,
        ee_state,
        doc_uname,
        tax_location,
        labor_distribution_profile,

        -- booleans
        case
            when on_leave = 1 then true
            when on_leave = 0 then false
        end as is_on_leave,

        -- dates
        date_hired::date as date_hired,
        date_rehired::date as date_rehired,
        date_terminated::date as date_terminated,
        position_effective_date::date as position_effective_date,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed
