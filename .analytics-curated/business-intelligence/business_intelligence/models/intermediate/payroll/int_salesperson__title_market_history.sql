{{ config(
    materialized='incremental',
    unique_key=['salesperson_key'],
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

{%- set scd_fields = ['employee_id', 'employee_title', 'employee_status', 'position_effective_date',
    'market_id', 'market_name', 'market_division_name', 'market_region', 'market_region_name', 'market_district' ] -%}

{{ convert_snapshot_to_scd2(
    source_relation = 'int_company_directory_history__salesperson',
    unique_key = ['employee_id'],
    updated_ts = '_valid_from',
    scd_fields = scd_fields,
    surrogate_key_name='salesperson_key'
) }}