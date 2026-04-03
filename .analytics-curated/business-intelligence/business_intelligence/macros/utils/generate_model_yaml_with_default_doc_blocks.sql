{#--
    Macro: generate_model_yaml_with_default_doc_blocks

    Description:
        Generates a `schema.yml`-formatted block for each model in the provided list,
        including column names, canonical dbt-style data types (via codegen), and 
        `description` fields using `doc()` references.
        Inserts newlines between models and between columns for improved readability.

    Args:
        model_names (list[str]):
            A list of model names (as strings) to inspect using `ref()`.

    Returns:
        A complete `schema.yml`-style YAML string that can be pasted into your project.

    Usage:
        {{ generate_model_yaml_with_default_doc_blocks(['stg_quotes', 'stg_users']) }}

    Notes:
        - Each column gets a `description: "{{ doc('column_name') }}"`
        - Uses codegen's data type formatter for canonical type naming
        - Models and columns are separated by newlines
--#}

{% macro generate_model_yaml_with_default_doc_blocks(model_names) %}
version: 2

models:
{%- for model_name in model_names %}

  - name: {{ model_name | lower }}
    description: "TODO: Add model description"
    columns:
{%- set relation = ref(model_name) -%}
{%- set columns = adapter.get_columns_in_relation(relation) %}
{%- for col in columns %}
{%- if not loop.first %}{{ '\n' }}{% endif %}
      - name: {{ col.name | lower }}
        data_type: {{ codegen.data_type_format_model(col) }}
        description: "{{ '{{ doc(\'' ~ col.name | lower ~ '\') }}' }}"
{%- endfor %}
{%- endfor %}
{% endmacro %}