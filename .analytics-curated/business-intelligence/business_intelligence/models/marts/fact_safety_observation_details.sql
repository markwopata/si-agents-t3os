{{ config(
    materialized='incremental',
    unique_key='safety_observation_key',
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with safety_observation_details as (
    SELECT
        safety_observation_id
        , submission_datetime
        , first_name
        , last_name
        , employee_email
        , branch_location
        , region
        , observation_category
        , observation_type
        , observation_date
        , observation_time_12h
        , observation_datetime
        , observation_datetime_final
        , observation_location
        , snowflake.cortex.summarize(observation_description) as observation_description_summary
        , observation_description
        , photos
        , corrective_action
        , corrective_action_type
        , corrective_action_explanation
        , requires_safety_manager_escalation
        , COALESCE(ARRAY_SIZE(photos), 0) > 0 as has_uploaded_photos
    FROM {{ ref('stg_jotform__safety_observation') }}
    WHERE {{ filter_source_updates('submission_datetime', buffer_amount=1, time_unit='day') }}
)

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_times as (
        SELECT  tm_key, tm_time_24
        FROM  {{ ref('platform', 'dim_times') }}
        where tm_hour <> -1
    )
    
    , cte_markets as (
        select market_key, market_id, market_name
        from {{ ref('platform', 'dim_markets') }}
        where market_active = TRUE
        and market_company_id = 1854
    )

    -- There can be multiple employees with the same email (ie. rehires that get assigned a new employee id instead of their old one)
    --  so we need to deduplicate
    , cte_employees as (
        select employee_key, employee_id
            , work_email
            , position_effective_date, date_hired, date_terminated
        from {{ ref('dim_employees') }}
        qualify row_number() over(partition by work_email 
                                  order by IFF(employee_status = 'Active', 0, 1),
                                           date_hired desc 
                                 ) = 1
    )

select 
    {{ dbt_utils.generate_surrogate_key(
        ['safety_observation_id']) 
    }} AS safety_observation_key
    , safety_observation_id  
    ,COALESCE(submission_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as safety_observation_submission_date_key
    ,COALESCE(submission_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as safety_observation_submission_time_key
    , COALESCE( 
        e.employee_key, 
        {{ get_default_key_from_dim(model_name='dim_employees') }}
    ) as safety_observation_employee_key
    , COALESCE(
        m.market_key, 
        {{ get_default_key_from_dim(model_name='dim_markets') }}
    ) as safety_observation_market_key
    ,COALESCE(observation_date.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as safety_observation_observation_date_key
    ,COALESCE(observation_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as safety_observation_observation_time_key
    ,COALESCE(observation_date_final.dt_key, 
        {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as safety_observation_observation_date_final_key
    ,COALESCE(observation_time_final.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as safety_observation_observation_time_final_key
    , observation_category
    , observation_type
    , observation_location
    , observation_description_summary
    , observation_description
    , corrective_action
    , corrective_action_type
    , corrective_action_explanation
    , requires_safety_manager_escalation
    , has_uploaded_photos

    ,{{ get_current_timestamp() }} AS _created_recordtimestamp
    ,{{ get_current_timestamp() }} AS _updated_recordtimestamp

from safety_observation_details safety
LEFT JOIN cte_employees e 
    ON lower(safety.employee_email) = lower(e.work_email)
LEFT JOIN cte_markets m 
    ON lower(safety.branch_location) = lower(m.market_name)
LEFT JOIN cte_dates submission_date
    ON safety.submission_datetime::date = submission_date.dt_date
LEFT JOIN cte_times submission_time 
    ON CAST(safety.submission_datetime::time AS string) = submission_time.tm_time_24
LEFT JOIN cte_dates observation_date
    ON safety.observation_datetime::date = observation_date.dt_date
LEFT JOIN cte_times observation_time
    ON CAST(safety.observation_datetime::time as string) = observation_time.tm_time_24
LEFT JOIN cte_dates observation_date_final
    ON safety.observation_datetime_final::date = observation_date_final.dt_date
LEFT JOIN cte_times observation_time_final
    ON CAST(safety.observation_datetime_final::time AS string) = observation_time_final.tm_time_24