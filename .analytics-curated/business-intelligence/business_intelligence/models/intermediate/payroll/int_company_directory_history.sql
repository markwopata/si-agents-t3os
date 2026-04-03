{{ config(
    materialized='incremental',
    unique_key=['employee_key'],
    incremental_strategy='merge'
) }}

with company_directory_history as (
    {{ convert_snapshot_to_scd2(
        source_relation = 'stg_payroll__company_directory_vault',
        unique_key = ['employee_id'],
        updated_ts = '_es_update_timestamp',
        surrogate_key_name='employee_key'
    ) }}
), 

position_effective_backfill as (
    SELECT 
        employee_id, 
        employee_title, 
        MIN(position_effective_date) AS backfill_position_effective_date, 
    FROM company_directory_history
    WHERE position_effective_date IS NOT NULL
    group by 1,2
)

-- position_effective_date got added in later, so for any employee with the same exact title 
-- that falls into the appropriate valid_from and valid_to, we can backfill the date
SELECT 
    base.employee_key,
    base.employee_id, 
    base.first_name,
    base.last_name,
    base.work_email,
    base.employee_type,
    base.employee_status,
    base.date_hired,
    base.date_rehired,
    base.employee_title,
    base.location,
    base.default_cost_centers_full_path,
    base.direct_manager_employee_id, 
    base.direct_manager_name,
    base.work_phone,
    base.date_terminated,
    base.nickname,
    base.personal_email,
    base.home_phone, 
    base.greenhouse_application_id,
    base.market_id, 
    base.account_id, 
    base.pay_calc,
    base.ee_state,
    base.doc_uname,
    base.tax_location,
    base.labor_distribution_profile,
    COALESCE(base.position_effective_date, bf.backfill_position_effective_date) as position_effective_date, 
    base.is_on_leave,
    base.worker_type,

    base._valid_from,
    base._valid_to,
    base._is_current,
    {{ dbt_updated_timestamp() }}

FROM company_directory_history base
LEFT JOIN position_effective_backfill bf 
ON base.employee_id = bf.employee_id 
AND base.employee_title = bf.employee_title  
AND base.position_effective_date IS NULL
AND (TIMESTAMPADD(SECOND, 86399, DATE_TRUNC('day', bf.backfill_position_effective_date)) BETWEEN base._valid_from AND base._valid_to
    OR bf.backfill_position_effective_date < base._valid_from)