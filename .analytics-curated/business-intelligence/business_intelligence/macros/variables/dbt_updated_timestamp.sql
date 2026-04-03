{%- macro dbt_updated_timestamp() -%}

CURRENT_TIMESTAMP()::TIMESTAMP_NTZ as _dbt_updated_timestamp

{%- endmacro -%}