{{ config(
    materialized='incremental',
    unique_key=['salesperson_key'],
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

{%- set salesperson_titles = var('salesperson_titles', []) -%}

with current_employee_data as (
        select 
            cd.employee_id,
            CASE
                WHEN POSITION(' ', COALESCE(cd.nickname, cd.first_name)) = 0 
                THEN CONCAT_WS(' ', COALESCE(cd.nickname, cd.first_name), cd.last_name)
                ELSE COALESCE(cd.nickname, CONCAT_WS(' ', cd.first_name, cd.last_name))
                END AS name_current,
            cd.work_email as employee_email_current,
            cd.worker_type as worker_type_current,
            cd.date_hired as date_hired_current,
            cd.date_rehired as date_rehired_current,
            cd.date_terminated as date_terminated_current,
            cd.direct_manager_employee_id as direct_manager_employee_id_current,
            cd.direct_manager_name as direct_manager_name_current
        from {{ ref('stg_payroll__company_directory') }} cd
    ),

    history_combined_current as (
        select scd.salesperson_key,
                scd.employee_id,
               cur.name_current,
               cur.employee_email_current,
               cur.worker_type_current,
               scd.employee_status as employee_status_hist,
               scd.market_division_name as market_division_name_hist,
               scd.market_id as market_id_hist,
               scd.market_name as market_name_hist,
               scd.market_region as market_region_hist,
               scd.market_region_name as market_region_name_hist,
               scd.market_district as market_district_hist,
               scd.employee_title as employee_title_hist,
               scd.position_effective_date as position_effective_date_hist,
               CASE WHEN scd.market_region = 0 THEN 'Unassigned'
                    WHEN scd.market_district = '0-0' THEN 'Region'
                    WHEN scd.market_id = -1 THEN 'District'
                    ELSE 'Market'
               END AS salesperson_jurisdiction,
               CASE WHEN scd.employee_title IN (
                    {%- for title in salesperson_titles %}
                    '{{ title }}'{% if not loop.last %}, {% endif %}
                    {%- endfor -%}
                ) 
                THEN TRUE 
                ELSE FALSE
                END AS has_salesperson_title,
               cur.date_hired_current,
               cur.date_rehired_current,
               cur.date_terminated_current,
               cur.direct_manager_employee_id_current,
               cur.direct_manager_name_current,
               scd._valid_from,
               scd._valid_to,
               scd._is_current
        FROM {{ ref('int_salesperson__title_market_history') }} scd 
        left join current_employee_data cur
        on scd.employee_id = cur.employee_id

        {% if is_incremental() -%}
        where scd._dbt_updated_timestamp > (select max(this._dbt_updated_timestamp) from {{ this }} this )
        {% endif -%}
    )

    SELECT *, 
        {{ dbt_updated_timestamp() }}

    FROM history_combined_current
