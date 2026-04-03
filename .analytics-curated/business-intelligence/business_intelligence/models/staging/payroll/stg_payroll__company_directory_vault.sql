with source as (

    select * from {{ source('payroll', 'company_directory_vault') }}

),

renamed as (

    select
        employee_id,
        first_name,
        last_name,
        work_email,
        employee_type,
        employee_status,
        TRY_TO_DATE(date_hired) as date_hired,
        TRY_TO_DATE(date_rehired) as date_rehired,
        employee_title,
        location,
        default_cost_centers_full_path,
        direct_manager_employee_id,
        direct_manager_name,
        work_phone,
        TRY_TO_DATE(date_terminated) as date_terminated,
        nickname,
        personal_email,
        home_phone,
        greenhouse_application_id,
        market_id,
        account_id,
        pay_calc,
        ee_state,
        doc_uname,
        tax_location,
        labor_distribution_profile,
        TRY_TO_DATE(position_effective_date) as position_effective_date,
        IFF(on_leave = 0, False, True) as is_on_leave,
        worker_type,
        _es_update_timestamp,
        {{ dbt_updated_timestamp() }}

    from source

)

select * from renamed