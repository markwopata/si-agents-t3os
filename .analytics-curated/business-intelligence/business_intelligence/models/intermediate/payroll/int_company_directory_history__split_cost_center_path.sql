{{ config(
    materialized='incremental',
    unique_key=['employee_key'],
    incremental_strategy='merge'
) }}

WITH latest_vault_data AS (
    -- One known pattern is 'Rental/R7 Industrial/3-3/Dallas, TX' and 'R7 Industrial/3-3/Dallas, TX', 
        -- so adding an extra '/' delimiter to the latter to match the former's format to simplify the parsing logic
    SELECT *
    FROM {{ ref('int_company_directory_history') }} scd

    {% if is_incremental() -%}
      WHERE scd._dbt_updated_timestamp > (SELECT MAX(this._dbt_updated_timestamp) FROM {{ this }} as this) 
    {%- endif -%}
),
    adjusted_cost_center_path as (
        SELECT DISTINCT default_cost_centers_full_path, 
            IFF(REGEXP_LIKE(LEFT(split_part(default_cost_centers_full_path, '/', 1), 2), 'R([1-9]|H)+'), -- match R1-R9 or RH
            '/' || default_cost_centers_full_path,
            default_cost_centers_full_path) as adjusted_path
        FROM {{ ref('int_company_directory_history') }} scd

        {% if is_incremental() -%}
        WHERE scd._dbt_updated_timestamp > (select max(this._dbt_updated_timestamp) from {{ this }} this)
        {%- endif -%}
    ),

    adjusted_paths as (
        select ld.*, p.adjusted_path
        from latest_vault_data ld
        left join adjusted_cost_center_path p 
        on ld.default_cost_centers_full_path = p.default_cost_centers_full_path
    ),

    cd_data_after_parse as (
        SELECT
            adj.*,
            parsed.division_name,
            parsed.region,
            parsed.region_name,
            parsed.district
        FROM adjusted_paths adj
        LEFT JOIN {{ ref('ep_company_directory_history__parse_cost_center_path') }} parsed
        ON adj.adjusted_path = parsed.adjusted_path
    )

    select 
        p.employee_key,
        p.employee_id, 
        p.first_name,
        p.last_name,
        p.work_email,
        p.employee_type,
        p.employee_status,
        p.date_hired,
        p.date_rehired,
        p.employee_title,
        p.location,
        p.default_cost_centers_full_path,
        p.direct_manager_employee_id, 
        p.direct_manager_name,
        p.work_phone,
        p.date_terminated,
        p.nickname,
        p.personal_email,
        p.home_phone, 
        p.greenhouse_application_id,
        p.account_id, 
        p.pay_calc,
        p.ee_state,
        p.doc_uname,
        p.tax_location,
        p.labor_distribution_profile,
        p.position_effective_date, 
        p.is_on_leave,
        p.worker_type,
        COALESCE(p.market_id, -1) AS market_id,
        m.market_name,
        IFF(m.market_division_name <> 'Unrecognized Division Name', m.market_division_name, coalesce(p.division_name, 'Unrecognized Division Name')) as market_division_name,
        IFF(m.market_region <> 0, m.market_region, coalesce(p.region, 0)) as market_region,
        IFF(m.market_region_name <> 'Default Region - Missing Value', m.market_region_name, coalesce(p.region_name, 'Default Region - Missing Value')) as market_region_name,
        IFF(m.market_district <> '0-0', m.market_district, coalesce(p.district, '0-0')) as market_district,
        p._valid_from,
        p._valid_to,
        p._is_current,

        {{ dbt_updated_timestamp() }}
    from cd_data_after_parse p
    left join {{ ref('platform', 'dim_markets') }} m
    on m.market_id = p.market_id