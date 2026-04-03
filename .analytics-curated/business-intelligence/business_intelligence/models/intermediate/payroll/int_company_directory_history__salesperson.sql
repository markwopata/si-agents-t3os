{{ config(
    materialized='incremental',
    unique_key=['employee_key'],
    incremental_strategy='merge'
) }}

with salespeople_history as (
    SELECT DISTINCT employee_id
    FROM {{ ref('int_company_directory_history') }}
    WHERE employee_title IN (
        {%- set salesperson_titles = var('salesperson_titles', []) -%}
        {%- for title in salesperson_titles %}
            '{{ title }}'{% if not loop.last %}, {% endif %}
        {%- endfor -%}
    )
)
select *
from {{ ref('int_company_directory_history__split_cost_center_path') }}
where employee_id in (
    select employee_id 
    from salespeople_history
)
{% if is_incremental() -%}
   AND _dbt_updated_timestamp > (SELECT MAX(this._dbt_updated_timestamp) FROM {{ this }} this )
{% endif -%}