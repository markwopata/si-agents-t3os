{% macro flatten_nested_fields(relation, exclude_cols=[]) %}
    {#
        Introspects a relation's VARIANT columns and returns a dict:
          - passthrough: non-VARIANT column names to select as-is
          - columns: list of {sql, alias} dicts for flattened fields

        Flattening rules (one level only):
          - FLAT fields             → col:"field"::string as prefix__field
          - OBJECT and ARRAY fields → col:"field" as prefix__field_raw (kept as VARIANT)

        Use flatten_field() to go deeper on a specific field.

        Args:
          relation:     a dbt relation (ref or source)
          exclude_cols: list of column names to omit from passthrough (uppercase)
    #}

    {%- set result = {'passthrough': [], 'columns': []} -%}

    {%- if not execute -%}
        {{ return(result) }}
    {%- endif -%}

    {%- set columns_query -%}
        select column_name, data_type
        from {{ relation.database }}.information_schema.columns
        where table_schema = '{{ relation.schema | upper }}'
        and table_name = '{{ relation.identifier | upper }}'
        order by ordinal_position
    {%- endset -%}

    {%- set variant_cols = [] -%}
    {%- for row in run_query(columns_query) -%}
        {%- set col_name  = row[0] -%}
        {%- set data_type = row[1] -%}
        {%- if col_name in exclude_cols -%}
            {# skip #}
        {%- elif data_type == 'VARIANT' -%}
            {%- do variant_cols.append(col_name) -%}
        {%- else -%}
            {%- do result.passthrough.append(col_name) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- for col in variant_cols -%}
        {%- set prefix = col | lower | replace('_raw', '') -%}

        {%- set sub_fields_query -%}
            select
                f.key::string as field_key,
                case
                    when max(case when typeof(f.value) = 'OBJECT' then 1 else 0 end) = 1 then 'OBJECT'
                    when max(case when typeof(f.value) = 'ARRAY'  then 1 else 0 end) = 1 then 'ARRAY'
                    else 'FLAT'
                end as field_type
            from {{ relation }},
            lateral flatten(input => {{ col }}) f
            group by 1
        {%- endset -%}

        {%- for row in run_query(sub_fields_query) -%}
            {%- set field      = row[0] -%}
            {%- set field_type = row[1] -%}
            {%- set alias      = field | replace('-', '_') -%}

            {%- if field_type == 'FLAT' -%}
                {%- do result.columns.append({
                    'sql':   col ~ ':"' ~ field ~ '"::string',
                    'alias': prefix ~ '__' ~ alias
                }) -%}
            {%- else -%}
                {%- do result.columns.append({
                    'sql':   col ~ ':"' ~ field ~ '"',
                    'alias': prefix ~ '__' ~ alias ~ '_raw'
                }) -%}
            {%- endif -%}
        {%- endfor -%}
    {%- endfor -%}

    {{ return(result) }}
{% endmacro %}
