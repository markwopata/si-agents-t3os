{{ config( 
    materialized='incremental',
    unique_key=['salesperson_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

with salesperson_details as (
    select 
        s.salesperson_key,
        u.user_id, 
        u.deleted as user_is_deleted,
        s.employee_id,
        s.employee_email_current,
        s.name_current,
        s.date_hired_current,
        s.date_rehired_current,
        s.date_terminated_current,
        s.has_salesperson_title,
        s.salesperson_jurisdiction,
        s.worker_type_current,

        s.market_division_name_hist,
        s.market_id_hist,
        s.market_name_hist,
        s.market_region_hist,
        s.market_region_name_hist,
        s.market_district_hist,
        s.employee_title_hist,
        s.position_effective_date_hist,
        s.employee_status_hist,

        s.first_salesperson_date,
        s.first_TAM_date,

        s.direct_manager_employee_id_current,
        s.direct_manager_name_current,
        dmu.user_id as direct_manager_user_id_current,
        dme.work_email as direct_manager_email_address_current,

        s._valid_from,
        s._valid_to,
        s._is_current

    from {{ ref('int_salesperson__hybrid__first_dates') }} s
    LEFT JOIN {{ref('int_bridge_user_employee') }} ueb
        ON ueb.employee_id = s.employee_id
    JOIN {{ ref('platform', 'users')}} u 
        ON ueb.user_id = u.user_id

    -- get manager details
    LEFT JOIN {{ ref('stg_payroll__company_directory') }} dme
        ON s.direct_manager_employee_id_current = dme.employee_id
    LEFT JOIN {{ ref('int_bridge_user_employee') }} dm_ueb
        ON dm_ueb.employee_id = s.direct_manager_employee_id_current
    LEFT JOIN {{ ref('platform', 'users')}} dmu
        ON dmu.user_id = dm_ueb.user_id

    {% if is_incremental() -%}
    where s._dbt_updated_timestamp > (select max(this._updated_recordtimestamp) from {{ this }} this )
    {% endif -%}
),

cte_full_list AS (

    {% if not is_incremental() -%}
        
    SELECT 
        {{ dbt_utils.generate_surrogate_key([-1, -1, '0001-01-01']) }} AS salesperson_key,
        -1 AS user_id,
        FALSE AS user_is_deleted,
        -1 AS employee_id,
        'Unknown Salesperson Email' AS employee_email_current,
        'Default Salesperson Record' AS name_current,
        '0001-01-01'::DATE AS date_hired_current,
        '0001-01-01'::DATE AS date_rehired_current,
        '0001-01-01'::DATE AS date_terminated_current,
        FALSE AS has_salesperson_title,
        'Unknown Salesperson Jurisdiction' AS salesperson_jurisdiction,
        'Unknown Worker Type' as worker_type_current,

        'Unrecognized Division Name' AS market_division_name_hist,
        -1 AS market_id_hist,
        'Unknown Market Name' AS market_name_hist,
        0 AS market_region_hist,
        'Default Region - Missing Value' AS market_region_name_hist,
        '0-0' AS market_district_hist,
        'Unknown Employee Title' AS employee_title_hist,
        '0001-01-01'::DATE AS position_effective_date_hist,
        'Default Salesperson Record' AS employee_status_hist,
        
        '0001-01-01'::DATE AS first_salesperson_date,
        '0001-01-01'::DATE AS first_TAM_date,
        
        -1 AS direct_manager_employee_id_current,
        'Unknown Direct Manager Name' AS direct_manager_name_current,
        -1 AS direct_manager_user_id_current,
        'Unknown Direct Manager Email' AS direct_manager_email_address_current,
        
        CAST('0001-01-01' AS TIMESTAMP_NTZ) AS _valid_from,
        CAST('9999-12-31 23:59:59' AS TIMESTAMP_NTZ) AS _valid_to,
        FALSE AS _is_current

    UNION ALL
    {%- endif %}

    SELECT
        salesperson_key,
        user_id,
        user_is_deleted,
        employee_id,
        employee_email_current,
        name_current,
        date_hired_current,
        date_rehired_current,
        date_terminated_current,
        has_salesperson_title,
        salesperson_jurisdiction,
        worker_type_current,

        market_division_name_hist,
        market_id_hist,
        market_name_hist,
        market_region_hist,
        market_region_name_hist,
        market_district_hist,
        employee_title_hist,
        position_effective_date_hist,
        employee_status_hist,
        
        first_salesperson_date,
        first_TAM_date,
        
        direct_manager_employee_id_current,
        direct_manager_name_current,
        direct_manager_user_id_current,
        direct_manager_email_address_current,
        
        _valid_from,
        _valid_to,
        _is_current

    FROM salesperson_details

)
    

SELECT  
    salesperson_key,
    user_id,
    user_is_deleted,
    employee_id,
    employee_email_current,
    name_current,
    date_hired_current,
    date_rehired_current,
    date_terminated_current,
    has_salesperson_title,
    salesperson_jurisdiction,
    worker_type_current,

    market_division_name_hist,
    market_id_hist,
    market_name_hist,
    market_region_hist,
    market_region_name_hist,
    market_district_hist,
    employee_title_hist,
    position_effective_date_hist,
    employee_status_hist,
    
    first_salesperson_date,
    first_TAM_date,
    
    direct_manager_employee_id_current,
    direct_manager_name_current,
    direct_manager_user_id_current,
    direct_manager_email_address_current,
    
    _valid_from,
    _valid_to,
    _is_current
    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp
from cte_full_list