{%- macro dbt_run_started_at_formatted() -%}

'{{ run_started_at.strftime("%Y-%m-%d %H:%M:%S.%f") }}'::TIMESTAMP_NTZ as _dbt_updated_timestamp

{%- endmacro -%}