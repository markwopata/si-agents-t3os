{{ config(
    materialized='incremental',
    unique_key=['camr_id'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

with app as (
    select *
    from {{ ref('stg_retool__credit_app_master_retool') }}
    WHERE ({{filter_source_updates(column_name='date_created_utc', buffer_amount=2, time_unit='hour', append_only=true)}})
)    

select
    app.camr_id
    , app.date_created_utc -- source system watermark
    , employee_email.user_id as created_by_employee_user_id
    , app.created_by_email
    , coalesce(
        m.user_id
        , salesperson_user.user_id
        , salesperson_employee.user_id
        , app.salesperson_user_id
    ) as salesperson_user_id
    , app.salesperson
    , app.salesperson_name
    , coalesce(
        m.employee_id
        , salesperson_employee.employee_id
        , salesperson_user.employee_id
        , app.salesperson_employee_id
    ) as salesperson_employee_id
    , coalesce(
        credit_specialist_user.user_id
        , credit_specialist_employee.user_id
        , app.credit_specialist_user_id
    ) as credit_specialist_user_id
    , app.credit_specialist
    , app.credit_specialist_name
    , coalesce(
        credit_specialist_employee.employee_id
        , credit_specialist_user.employee_id
        , app.credit_specialist_employee_id
    ) as credit_specialist_employee_id

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from app

-- seems like only admin-level employees under ES (1854) potentially pouplate the created_by_email field
left join (
    SELECT user_id, lower(email_address) as email_address
    FROM {{ ref('platform', 'users') }}
    WHERE security_level_id = 1 -- admin
    AND company_id = 1854
) employee_email
on employee_email.email_address = lower(app.created_by_email)

left join {{ ref('int_credit_app_map_missing_salesperson_user_id') }} m 
    ON m.camr_id = app.camr_id

left join {{ ref('int_bridge_user_employee') }} salesperson_user
on app.salesperson_user_id = salesperson_user.user_id
left join {{ ref('int_bridge_user_employee') }} salesperson_employee
on app.salesperson_employee_id = salesperson_employee.employee_id
left join {{ ref('int_bridge_user_employee') }} credit_specialist_user
on app.salesperson_user_id = credit_specialist_user.user_id
left join {{ ref('int_bridge_user_employee') }} credit_specialist_employee
on app.salesperson_employee_id = credit_specialist_employee.employee_id