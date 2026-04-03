{#--
    Macro: remove_column_from_model

    Description:
        This macro removes a column from the model.

    Args:
        model (str): The name of the model (typically a ref() string, like 'stg_table').
        column_name: The name of the column you want to remove.
        dry_run (bool): false if we want to override the table; true if we are just testing

    Returns:
        Nothing. 
        If dry_run is set to true, it will only print out the before and after column count.
        If dry_run is false, it'll drop the column from the model.

    Usage:
        dbt run-operation remove_column_from_model --args '{ "model": "stg_t3__telematics_health_snapshot", "column_name": "DATA_REFRESH_TIMESTAMP", "dry_run": true}'
--#}

{%- macro remove_column_from_model(model, column_name, dry_run=true) -%}
  {# Resolve the relation from the ref #}
  {%- set rel = ref(model | lower) -%}

  {# Standardize column_name input #}
  {%- set requested_drop_col = column_name | upper -%}

  {# Current columns #}
  {%- set cols_before = adapter.get_columns_in_relation(rel) -%}
  {%- set current_col_names = cols_before | map(attribute='name') | map('upper') | list -%}
  {%- set before_col_count = cols_before | length -%}

  {# Safety: block snapshot metadata columns #}
  {%- set protected = ['DBT_SCD_ID','DBT_UPDATED_AT','DBT_VALID_FROM','DBT_VALID_TO'] -%}
  {%- if requested_drop_col in protected -%}
    {{ log("Not allowed to drop protected snapshot column '" ~ column_name ~ "'.", info=True) }}
    {%- do return(none) -%}
  {%- endif -%}

  {# Only drop if it exists #}
  {%- if requested_drop_col in current_col_names -%}
    
    {{ log("[" ~ model ~ "] columns BEFORE: " ~ before_col_count, info=True) }}

    {# Get exact column name from database #}
    {{ log("Target database: " ~ rel.database, info=True) }}
    {{ log("Target schema: " ~ rel.schema, info=True) }}
    {{ log("Target table name: " ~ rel.identifier, info=True) }}
    {%- set sql -%}
        select column_name
        from {{ rel.database }}.information_schema.columns
        where upper(table_schema) = upper('{{ rel.schema }}')
        and upper(table_name)  = upper('{{ rel.identifier }}')
        and upper(column_name) = upper('{{ requested_drop_col }}')
        limit 1
    {%- endset -%}
    {%- set res = run_query(sql) -%}
    {{ log("res: " ~ res, info=True) }}
    {%- set actual_column_name = (res and res.rows and res.rows|length > 0) and res.rows[0][0] or none -%}
    {{ log("actual_column_name: " ~ actual_column_name, info=True) }}

    {%- if actual_column_name is none -%}
        {{ log("Edge case issue - having trouble with column '" ~ column_name ~ "'; aborting.", info=True) }}
    {%- elif dry_run -%}
        {{ log("DRY RUN: Would drop column '" ~ actual_column_name ~ "' on " ~ rel, info=True) }}
        {{ log("[" ~ model ~ "] columns AFTER (simulated): " ~ (before_col_count - 1), info=True) }}
    {%- else -%}
        {%- set sql %}alter table {{ rel }} drop column {{ adapter.quote(actual_column_name) }}{% endset -%}
        {%- do run_query(sql) -%}

        {# Column check after drop #}
        {%- set cols_after = adapter.get_columns_in_relation(rel) -%}
        {%- set after_col_count = cols_after | length -%}

        {{ log("Dropped column '" ~ actual_column_name ~ "' on " ~ rel, info=True) }}
        {{ log("[" ~ model ~ "] columns AFTER: " ~ after_col_count, info=True) }}
    {%- endif -%}
  {%- else -%}
        {{ log("Column '" ~ column_name ~ "' not found on " ~ rel ~ " (skipping)", info=True) }}
        {{ log("[" ~ model ~ "] columns AFTER: " ~ before_col_count, info=True) }}
  {%- endif -%}

{%- endmacro -%}