{{ config(
    materialized='incremental'
    , unique_key=['company_key']
    , incremental_strategy='merge'
    , merge_exclude_columns = ['_created_recordtimestamp']
) }}

with app as (
    select
        company_id,
        camr_id,
        source,
        app_status,
        app_type,
        first_account_date_ct,
        salesperson_user_id,
        notes,
        is_locked

    from {{ ref('int_credit_app_first_intake_resolved') }} app
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

    , cte_salesperson as (
        select salesperson_key, user_id, _valid_from, _valid_to
        from {{ ref('dim_salesperson_enhanced') }}
    )

select
    COALESCE(
        c.company_key,
        {{ get_default_key_from_dim(model_name='dim_companies') }}
    ) as company_key
    , COALESCE(
        salesperson_user.user_key,
        {{ get_default_key_from_dim(model_name='dim_users') }}
    ) as salesperson_user_key
    , COALESCE(
        salesperson.salesperson_key,
        {{ get_default_key_from_dim(model_name='dim_salesperson_enhanced') }}
    ) as salesperson_key
    , COALESCE(
        first_account_date_ct.dt_key,
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as first_account_date_ct_key

    , app.app_type as credit_application_type
    , app.source as first_account_source
    , app.notes
    , app.is_locked

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from app

LEFT JOIN cte_companies c 
    ON c.company_id = app.company_id
LEFT JOIN cte_dates first_account_date_ct
    ON first_account_date_ct.dt_date = app.first_account_date_ct
LEFT JOIN cte_users salesperson_user
    ON salesperson_user.user_id = app.salesperson_user_id
LEFT JOIN cte_salesperson salesperson 
    ON salesperson.user_id = app.salesperson_user_id 
    AND CAST(app.first_account_date_ct AS TIMESTAMP) >= salesperson._valid_from
    AND CAST(app.first_account_date_ct AS TIMESTAMP) < salesperson._valid_to