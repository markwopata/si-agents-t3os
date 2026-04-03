{{ config(
    materialized='incremental',
    unique_key=['employee_id'],
    incremental_strategy='delete+insert'
) }} 

WITH 
    prior_day as (
        select DATEADD('day', -1, CURRENT_DATE) as prev_day
    ),

    -- 1) changed rows in employee or user source tables
    updated_employees as (
        select
            employee_id
        from {{ ref('stg_payroll__company_directory')}}

        {% if is_incremental() -%}
        WHERE last_updated_date::date = (SELECT prev_day from prior_day) 
        {%- endif -%}
    )

    , updated_users as (
        select u.user_id
        from {{ ref('platform', 'users') }} u
        where company_id = 1854
        {% if is_incremental() -%}
        AND (date_created::date = (SELECT prev_day from prior_day)
            OR date_updated::date = (SELECT prev_day from prior_day)
            OR _users_effective_start_utc_datetime::date = (SELECT prev_day from prior_day)
        )
        {%- else -%}
        AND try_cast(employee_id as number) is not null
        {%- endif -%}
    )

    -- 2) combine all employee id changes
    , affected_employee_ids as (
        -- Employees updated in payroll system
        select employee_id from updated_employees

        union
        -- Current employee_id for updated users
        select try_cast(u.employee_id as number) as employee_id
        from {{ ref('platform', 'users') }} u
        where u.user_id in (select user_id from updated_users)
        and try_cast(u.employee_id as number) is not null

        {% if is_incremental() -%}
        union
        -- Previous employee_id for updated users
        select bridge.employee_id
        from {{ this }} bridge
        where bridge.user_id in (select user_id from updated_users)
        {%- endif -%}
    )

    -- 3) filter for the employee ids in employee or user source tables
    , employees as (
        select
            employee_id,
            lower(work_email) as employee_email,
            first_name, last_name
        from {{ ref('stg_payroll__company_directory')}}
        {% if is_incremental() -%}
        WHERE employee_id in (select employee_id from affected_employee_ids)
        {%- endif -%}
    )

    , users as (
        select
            user_id
            , email_address
            , regexp_replace(lower(email_address), '^deleted-[0-9]+-', '') as cleaned_email_address
            , try_cast(employee_id as number) as employee_id 
            
        from {{ ref('platform', 'users') }} u
        where try_cast(employee_id as number) is not null
        AND company_id = 1854
        {% if is_incremental() -%}
        AND employee_id in (select employee_id from affected_employee_ids)
        {%- endif -%}
    )

    -- 4) user -> employee identity mapping
    , user_to_employee_joined_by_employee_id as (
        select
            u.user_id,
            u.email_address,
            u.cleaned_email_address,
            e.employee_id,
            e.employee_email, e.first_name, e.last_name
        from users u
        join employees e
        on u.employee_id = e.employee_id
    )

    -- 5) retry with email for any that don't tie by id (handful of cases)
    , user_to_employee_joined_by_email as (
        select
            u.user_id,
            u.email_address,
            u.cleaned_email_address,
            e.employee_id, e.employee_email, e.first_name, e.last_name
        from users u 
        join employees e
        on u.cleaned_email_address = e.employee_email
        and u.user_id not in (select user_id from user_to_employee_joined_by_employee_id)
    )

    , successful_identity as (
        select user_id,
                email_address,
                employee_id,
                employee_email, first_name, last_name
        from user_to_employee_joined_by_employee_id
        union all
        select user_id,
                email_address,
                employee_id,
                employee_email, first_name, last_name
        from user_to_employee_joined_by_email
    )

    select user_id, 
            email_address,
            employee_id,
            employee_email,
            first_name,
            last_name,
            
            {{ get_current_timestamp() }} AS _updated_recordtimestamp
    from successful_identity
    where user_id not in (
        169213, -- outlier that has the same employee id (8513) as user_id 187168
        83236 -- outlier that has the same employee id (14676) as user_id 289399
    )