{#--
    Macro: select_except

    Description:
        Returns either a list or comma-separated string of column names from a relation,
        excluding specified fields (case-insensitive).

        Comma-separated string is useful for SELECT * - style logic, where you want to project all columns except
        specific audit fields (e.g., `_dbt_updated_timestamp` or `_es_update_timestamp`).

    Args:
        ref_relation (str): The name of the relation to inspect (typically a ref() string, like 'stg_table').
        exclude (list[str], optional): A list of column names to exclude from the selection.
            Matching is case-insensitive.
        return_as (str, optional): 'list' (default) or 'string'. Controls output format.

    Returns:
        str: A comma-separated string of column names, each on its own line and indented,
            suitable for use directly in a SELECT clause.

    Example:
         {% set fields = select_except('stg_table', ['_dbt_updated_timestamp']) %}
        SELECT {{ fields | join(', ') }} FROM {{ ref('stg_table') }}

        Or directly:
        SELECT {{ select_except('stg_table', exclude=['meta'], return_as='string') }} FROM ...
--#}

{%- macro get_columns_except(ref_relation, exclude=[], return_as='string') -%}

    {%- set relation = ref(ref_relation) if (ref_relation is string) else ref_relation -%}
    {%- set columns = adapter.get_columns_in_relation(relation) -%}

    {%- set exclude_lower = [] -%}
    {%- for col in exclude -%}
        {% do exclude_lower.append(col.lower()) %}
    {%- endfor -%}
    
    {%- set selected = [] -%}

    {%- for col in columns -%}
        {%- if col.name.lower() not in exclude -%}
            {% do selected.append(col.name) %}
        {%- endif %}
    {%- endfor %}

    {%- if return_as == 'string' -%}
        {{ return(selected | join(',\n    ')) }}
    {%- else -%}
        {{ return(selected) }}
    {%- endif -%}

{%- endmacro -%}