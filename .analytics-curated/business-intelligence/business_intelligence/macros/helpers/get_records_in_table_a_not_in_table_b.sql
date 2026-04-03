{%- macro get_records_in_table_a_not_in_table_b(table_a_ref, table_b_ref, join_keys, null_identifier) -%}

    {%- do log("Running get_records_in_table_a_not_in_table_b macro", info=True) -%}

    {%- if join_keys is iterable and join_keys is not string and join_keys is mapping -%} {# check for dict #}
        {%- set join_iterable = join_keys -%}
    {%- elif my_var is sequence and my_var is not string -%} {# check for list #}
        {%- set join_iterable = dict(zip(join_keys, join_keys)) -%}
    {%- else -%}
        {{ exceptions.raise_compiler_error('Invalid join_keys format: Expected a list or dictionary.') }}
    {%- endif -%}

    select a.*
    from ({{ table_a_ref }}) a
    left join ( {{table_b_ref}} ) b
    on {%- for a_col, b_col in join_iterable.items() %}
            {% if not loop.first %} AND {% endif %} a.{{ a_col }} = b.{{ b_col }}
        {% endfor %}
    where b.{{null_identifier}} is null

{%- endmacro -%}

