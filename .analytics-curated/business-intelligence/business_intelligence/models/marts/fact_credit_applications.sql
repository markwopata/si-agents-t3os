{{ config(
    materialized='incremental'
    , unique_key=['credit_application_camr_id']
    , incremental_strategy='merge'
    , merge_exclude_columns = ['_created_recordtimestamp']
) }}

with app as (
        select 
            company_id
            , camr_id
        from {{ ref('int_credit_app_lookup_current_application') }} 
        -- ensure company exists in dim in case of timing issues
        where company_id in (
            select company_id 
            from {{ ref('platform', 'dim_companies') }}
        )

        {% if is_incremental() -%}
        and ( {{ filter_incremental_with_buffer_day('_updated_recordtimestamp', buffer_days=1 ) }} )
        {%- endif -%}
    )

    , cte_companies as (
        select company_key, company_id
        from {{ ref('platform', 'dim_companies') }}
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

select 
    COALESCE( 
        c.company_key, 
        {{ get_default_key_from_dim(model_name='dim_companies') }}
    ) as company_key
    , COALESCE( 
        created_by_employee.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as created_by_employee_user_key
    , COALESCE( 
        salesperson_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as salesperson_user_key
    , COALESCE( 
        cs_user.user_key, 
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as credit_specialist_user_key
    , COALESCE( 
        created_date.dt_key
        , {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as created_date_key
    , COALESCE( 
        received_date.dt_key
        , {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as received_date_key
    , COALESCE( 
        completed_date.dt_key
        , {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as completed_date_key
    
    , app.camr_id as credit_application_camr_id
    , rd.app_status as credit_application_status
    , rd.app_type as credit_application_type
    , rd.source as credit_application_source
    , rd.notes as credit_application_notes

    , rd.duns
    , rd.fein
    , rd.sic
    , rd.naics_primary
    , rd.naics_secondary

    , rd.has_insurance_info
    , rd.coi_received
    , rd.insurance_company
    , rd.insurance_email
    , rd.insurance_phone

    , rd.credit_safe_no
    , rd.is_government_entity
    , rd.has_online_app_status
    , rd.is_salesperson_override
    , rd.is_initial_web_self_signup
    , rd.is_initial_web_unauthenticated
    , rd.unauthenticated_dot_com_app_id
    , rd.is_automated_entry

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp 
    
from app
JOIN {{ ref('int_credit_app_base') }} rd
    ON app.camr_id = rd.camr_id

LEFT JOIN cte_companies c 
    ON c.company_id = app.company_id
LEFT JOIN cte_users created_by_employee
    ON created_by_employee.user_id = rd.created_by_employee_user_id
LEFT JOIN cte_users salesperson_user
    ON salesperson_user.user_id = rd.salesperson_user_id
LEFT JOIN cte_users cs_user
    ON cs_user.user_id = rd.credit_specialist_user_id

LEFT JOIN cte_dates created_date
    ON created_date.dt_date = rd.date_created_ct::date
LEFT JOIN cte_dates received_date
    ON received_date.dt_date = rd.date_received_ct
LEFT JOIN cte_dates completed_date
    ON completed_date.dt_date = rd.date_completed_ct
