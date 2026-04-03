{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = env_var('DBT_SCHEMA_DEV', 'default_dev_schema') -%}
    {# In dev, ignore any custom schema and always use DBT_SCHEMA_DEV (or fallback) #}

    {%- if target.name == 'dev' -%}
        {{ default_schema }}

    {%- elif custom_schema_name is none -%}
        {{ target.schema }}

    {%- else -%}
        {{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}
