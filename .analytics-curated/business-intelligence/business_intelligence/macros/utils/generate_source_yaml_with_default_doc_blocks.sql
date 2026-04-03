{#--
    Macro: generate_source_yaml_with_default_doc_blocks

    Description:
        Generates a `schema.yml`-formatted block for sources with detailed metadata.
        Groups tables under the same source block, includes `database`, `schema`, and
        auto-generates column metadata with doc() references.

    Args:
        source_definitions (list[dict]):
            Each dict must include:
              - source_name
              - database
              - schema
              - description (optional)
              - tables: list of table names

    Example Input:
        [
            {
                'source_name': 'payroll',
                'database': 'analytics',
                'schema': 'payroll',
                'description': 'Payroll source tables',
                'tables': ['employees', 'salaries']
            }
        ]

    Usage:
        {{ generate_source_yaml_with_default_doc_blocks([
            {'source_name': 'payroll', 'database': 'analytics', 'schema': 'payroll', 'description': '...', 'tables': ['employees']}
        ]) }}
--#}

{% macro generate_source_yaml_with_default_doc_blocks(source_definitions) %}
version: 2

sources:
{%- for src in source_definitions %}
  - name: {{ src.source_name | lower }}
    description: "{{ src.description | default('') }}"
    database: {{ src.database }}
    schema: {{ src.schema }}
    tables:
{%- for table_name in src.tables %}
      - name: {{ table_name | lower }}
        description: "TODO: Add table description"
        columns:
{%- set relation = source(src.source_name, table_name) %}
{%- set columns = adapter.get_columns_in_relation(relation) %}
{%- for col in columns %}
{%- if not loop.first %}{{ '\n' }}{% endif %}
          - name: {{ col.name | lower }}
            data_type: {{ codegen.data_type_format_model(col) }}
            description: "{{ '{{ doc(\'' ~ col.name | lower ~ '\') }}' }}"
{%- endfor %}
{%- endfor %}

{%- endfor %}
{% endmacro %}
