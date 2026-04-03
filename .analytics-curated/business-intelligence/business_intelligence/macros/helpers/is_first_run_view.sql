{%- macro is_first_run() -%}
    {%- set relation = this  -%}
    {%- set table_exists = adapter.get_relation(
        database=relation.database,
        schema=relation.schema,
        identifier=relation.identifier
    ) is not none -%}

    {%- if not table_exists -%}
        {{ return(true) }}
    {%- else -%}
        {%- set row_count_query -%}
            SELECT COUNT(*) FROM {{ relation }}
        {%- endset -%}

        {%- set result = run_query(row_count_query) -%}
        {%- set row_count = result.columns[0].values()[0] -%}

        {{ return(row_count == 0) }}
    {%- endif -%}
{%- endmacro -%}