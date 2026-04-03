{{ config( 
    materialized='incremental',
    unique_key=['employee_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH employees AS (
    SELECT 
        employee_id
        , first_name
        , nickname
        , last_name
        , work_email
        , work_phone
        , personal_email
        , home_phone
        , employee_type
        , employee_status
        , employee_title
        , position_effective_date
        , date_hired
        , date_rehired
        , date_terminated
        , is_on_leave
        , location
        , default_cost_centers_full_path
        , greenhouse_application_id
        , direct_manager_employee_id
        , market_id
        , account_id
        , pay_calc
        , ee_state
        , doc_uname
        , tax_location
        , labor_distribution_profile
        , worker_type

    FROM {{ ref('stg_payroll__company_directory') }} cd 
    WHERE employee_status <> 'Never Started'
    {% if is_incremental() %}
    AND (
        last_updated_date >= (SELECT MAX(this._updated_recordtimestamp) FROM {{ this }} as this) 
    )
    {% endif %}
)
    , cte_full_list AS (
        {% if not is_incremental() -%}
        SELECT 
            -1 AS employee_id
            , 'Default' AS first_name
            , 'Default' AS nickname
            , 'Default' AS last_name
            , 'Default' AS work_email
            , 'Default' AS work_phone
            , 'Default' AS personal_email
            , 'Default' AS home_phone
            , 'Default' AS employee_type
            , 'Default' AS employee_status
            , 'Default' AS employee_title
            , '0001-01-01'::DATE AS position_effective_date
            , '0001-01-01'::DATE AS date_hired
            , '0001-01-01'::DATE AS date_rehired
            , '0001-01-01'::DATE AS date_terminated
            , FALSE AS is_on_leave
            , 'Default' AS location
            , 'Default' AS default_cost_centers_full_path
            , -1 AS greenhouse_application_id
            , -1 as direct_manager_employee_id
            , -1 AS market_id
            , 'Default' AS account_id
            , 'Default' AS pay_calc
            , 'Default' AS ee_state
            , 'Default' AS doc_uname
            , 'Default' AS tax_location
            , 'Default' AS labor_distribution_profile
            , 'Default' AS worker_type
        UNION ALL
        {%- endif %}
        SELECT
            employee_id
            , first_name
            , nickname
            , last_name
            , work_email
            , work_phone
            , personal_email
            , home_phone
            , employee_type
            , employee_status
            , employee_title
            , position_effective_date
            , date_hired
            , date_rehired
            , date_terminated
            , is_on_leave
            , location
            , default_cost_centers_full_path
            , greenhouse_application_id
            , direct_manager_employee_id
            , market_id
            , account_id
            , pay_calc
            , ee_state
            , doc_uname
            , tax_location
            , labor_distribution_profile
            , worker_type

        FROM employees
    ) 

    -- check if direct_manager_employee_id is valid / ties back to the table
    , employee_manager_check as (
        select employees.employee_id, 
            case 
                when employees.direct_manager_employee_id is null then -1              -- no manager
                when manager.employee_id is not null then employees.direct_manager_employee_id -- manager exists
                else -1                                                       -- invalid manager reference
            end as manager_employee_id
        from cte_full_list employees 
        left join {{ ref('stg_payroll__company_directory') }} manager
        ON employees.direct_manager_employee_id = manager.employee_id
    )

    , dim_employees_base AS (
        select 
            {{ dbt_utils.generate_surrogate_key(['employee_id']) }} AS employee_key
            , *
        from cte_full_list employee
    )

    , manager_key as (
        select employee_id, 
             {{ dbt_utils.generate_surrogate_key(['manager_employee_id']) }} AS manager_employee_key
        from employee_manager_check 
    )

    , cte_markets as (
        select market_key, market_id 
        from {{ ref('platform', 'dim_markets') }}
    )

SELECT 
    employee_key
    , e.employee_id
    , first_name
    , nickname
    , last_name
    , work_email
    , work_phone
    , personal_email
    , home_phone
    , employee_type
    , employee_status
    , employee_title
    , position_effective_date
    , date_hired
    , date_rehired
    , date_terminated
    , is_on_leave
    , location
    , default_cost_centers_full_path
    , manager.manager_employee_key
    , greenhouse_application_id
    , COALESCE(m.market_key, 
        {{ get_default_key_from_dim(model_name='dim_markets') }}
    ) as market_key
    , account_id
    , pay_calc
    , ee_state
    , doc_uname
    , tax_location
    , labor_distribution_profile
    , worker_type

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM dim_employees_base e 
LEFT JOIN cte_markets m 
on m.market_id = e.market_id
JOIN manager_key manager 
on manager.employee_id = e.employee_id
