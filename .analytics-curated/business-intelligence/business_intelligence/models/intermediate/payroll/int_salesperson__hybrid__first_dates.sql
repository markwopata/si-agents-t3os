 {{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    partition_by=['employee_id']
) }}

{%- set salesperson_titles = var('salesperson_titles', []) -%} 
{%- set TAM_titles = ['Territory Account Manager', 'Strategic Account Manager', 'Rental Territory Manager'] %}

WITH first_salesperson as (
   {{ get_first_salesperson_dates(
    source_model='int_salesperson__hybrid',
    title_list=salesperson_titles
    ) }}
),

first_TAM as (
    {{ get_first_salesperson_dates(
    source_model='int_salesperson__hybrid',
    title_list=TAM_titles
    ) }}
)

SELECT s.salesperson_key,
        s.employee_id,
        s.employee_email_current,
        s.name_current,
        s.worker_type_current,
        s.salesperson_jurisdiction,
        s.date_hired_current,
        s.date_rehired_current,
        s.date_terminated_current,
        s.employee_status_hist,
        s.market_division_name_hist,
        s.market_id_hist,
        s.market_name_hist,
        s.market_region_hist,
        s.market_region_name_hist,
        s.market_district_hist,
        s.employee_title_hist,
        case 
        when s.employee_title_hist IN (
            {%- for title in salesperson_titles %}
            '{{ title }}'{% if not loop.last %}, {% endif %}
            {%- endfor -%}
        ) 
        then true
        else false
        end as has_salesperson_title,
        s.position_effective_date_hist,

        salesperson.start_date as first_salesperson_date,
        TAM.start_date as first_TAM_date,
        
        s.direct_manager_employee_id_current,
        s.direct_manager_name_current,

        s._valid_from,
        s._valid_to,
        s._is_current,
        {{ dbt_updated_timestamp() }}

    FROM {{ ref('int_salesperson__hybrid') }}  s
    LEFT JOIN first_salesperson salesperson
    ON s.employee_id = salesperson.employee_id
    LEFT JOIN first_TAM TAM
    on s.employee_id = TAM.employee_id