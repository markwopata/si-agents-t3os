{% macro flatten_field(relation, column_path, prefix=none) %}
    {#
        Flattens one specific VARIANT field/path in a relation and returns column definitions.

        Args:
          relation:    a dbt relation (ref or source)
          column_path: the column or path to flatten, e.g. 'KAFKA_HEADERS_RAW'
                       or 'CONTENT_DATA_RAW:operator_assignment'
          prefix:      optional alias prefix; derived from column_path if not provided

        Returns:
          { 'columns': [{'sql': ..., 'alias': ...}] }
    #}

    {%- if prefix is none -%}
        {%- set prefix = column_path | lower | replace(':', '__') | replace('_raw', '') -%}
    {%- endif -%}

    {%- set result = {'columns': []} -%}

    {%- if not execute -%}
        {{ return(result) }}
    {%- endif -%}

    {%- set query -%}
        select
            f.key::string as field_key,
            case
                when max(case when typeof(f.value) = 'OBJECT' then 1 else 0 end) = 1 then 'OBJECT'
                when max(case when typeof(f.value) = 'ARRAY'  then 1 else 0 end) = 1 then 'ARRAY'
                else 'FLAT'
            end as field_type
        from {{ relation }},
        lateral flatten(input => {{ column_path }}) f
        group by 1
    {%- endset -%}

    {%- for row in run_query(query) -%}
        {%- set field      = row[0] -%}
        {%- set field_type = row[1] -%}
        {%- set alias      = field | replace('-', '_') -%}

        {%- if field_type == 'FLAT' -%}
            {%- do result.columns.append({
                'sql':   column_path ~ ':"' ~ field ~ '"::string',
                'alias': prefix ~ '__' ~ alias
            }) -%}
        {%- else -%}
            {%- do result.columns.append({
                'sql':   column_path ~ ':"' ~ field ~ '"',
                'alias': prefix ~ '__' ~ alias ~ '_raw'
            }) -%}
        {%- endif -%}
    {%- endfor -%}

    {{ return(result) }}
{% endmacro %}
