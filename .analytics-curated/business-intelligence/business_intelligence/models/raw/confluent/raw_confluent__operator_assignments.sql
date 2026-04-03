{%- set schema = flatten_nested_fields(
    source('confluent', 'operator_assignments')
) -%}

select
    {%- for col in schema.passthrough %}
    {{ col }},
    {%- endfor %}
    {%- for col in schema.columns %}
    {{ col.sql }} as {{ col.alias }},
    {%- endfor %}

    {{ get_current_timestamp() }} as _updated_recordtimestamp
from {{ source('confluent', 'operator_assignments') }}
