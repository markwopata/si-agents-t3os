{#--
    Macro: generate_doc_blocks_for_models

    Description:
        Takes a list of model names, collects all column names, deduplicates them,
        and generates reusable `doc()` blocks (one per unique column name), with
        a newline between each for readability.

    Args:
        model_names (list[str]): List of model names (e.g., ['stg_quotes', 'stg_users'])

    Returns:
        A clean Markdown-style block of reusable doc strings.

    Usage:
        {{ generate_doc_blocks_for_models(['stg_quotes', 'stg_users']) }}
--#}

{% macro generate_doc_blocks_for_model(model_names) %}
{%- set seen = [] -%}

{%- set exclude_columns = ['_dbt_updated_timestamp', '_es_updated_timestamp', 'vaild_from', 'valid_to', 'is_current'] -%}

{%- for model_name in model_names %}
  {%- set relation = ref(model_name) -%}
  {%- set columns = adapter.get_columns_in_relation(relation) -%}

  {%- for col in columns %}
    {%- set col_name_lower = col.name | lower %}
    {%- if col_name_lower not in seen and col_name_lower not in exclude_columns %}
      {%- do seen.append(col_name_lower) %}

{% raw %}{% docs {% endraw %}{{ col_name_lower }}{% raw %} %}{% endraw %}
Identifier or description for `{{ col.name }}`.
{% raw %}{% enddocs %}{% endraw %}

    {%- endif %}
  {%- endfor %}
{%- endfor %}
{% endmacro %}

