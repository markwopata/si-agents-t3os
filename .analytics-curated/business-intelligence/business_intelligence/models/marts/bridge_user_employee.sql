{{ config(
    materialized='incremental',
    unique_key=['user_key'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

WITH

    cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )
    
    , cte_employees as (
        select employee_key, employee_id
        from {{ ref('dim_employees') }}
    )

    , bridge as (
        select *
        from {{ ref('int_bridge_user_employee') }} br 
        where (
            {{ filter_incremental_with_buffer_minute(column_name='_updated_recordtimestamp', buffer_minutes=30) }}
        )
    )

    select 
        u.user_key
        , e.employee_key
        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp
    from bridge 
    join cte_users u 
    on bridge.user_id = u.user_id 
    join cte_employees e 
    on bridge.employee_id = e.employee_id