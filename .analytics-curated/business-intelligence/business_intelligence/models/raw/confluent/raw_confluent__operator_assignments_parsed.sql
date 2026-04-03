{%- set parent = ref('raw_confluent__operator_assignments') -%}

{%- set schema     = flatten_nested_fields(parent, exclude_cols=['_CREATED_RECORDTIMESTAMP', '_UPDATED_RECORDTIMESTAMP']) -%}
{%- set op_asgmt   = flatten_field(parent, 'RECORD_CONTENT__DATA_RAW:operator_assignment') -%}

select
    {%- for col in schema.passthrough %}
    {{ col }},
    {%- endfor %}
    {%- for col in schema.columns %}
    {{ col.sql }} as {{ col.alias }},
    {%- endfor %}
    {%- for col in op_asgmt.columns %}
    {{ col.sql }} as {{ col.alias }},
    {%- endfor %}
    
    {{ get_current_timestamp() }} as _updated_recordtimestamp

from {{ parent }}

qualify row_number() over (
    partition by record_content__id
    order by record_metadata__CreateTime::number desc
) = 1
