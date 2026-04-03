{#--
    Macro: update_column_data_type

    Description:
        Changes a column's data type in-place by:
        1. Adding a new column with the target type
        2. Copying/casting data from old to new column
        3. Dropping the old column
        4. Renaming new column to old name

    Args:
        model (str): dbt model name (e.g., 'int_quote_line_items')
        column_name (str): Column to change (e.g., 'flat_rate')
        new_type (str): Target data type (e.g., 'number')
        dry_run (bool): If true, only logs SQL without executing (default: true)

    Usage:
        # Preview the SQL (no changes):
        dbt run-operation update_column_data_type --args '{
          "model": "int_quote_sale_items",
          "column_name": "price",
          "new_type": "number",
          "dry_run": true
        }'
--#}

{%- macro update_column_data_type(model, column_name, new_type, dry_run=true) -%}

  {#--- Find the model node ---#}
  {%- set target_name = model | lower -%}
  {%- set candidates = [] -%}
  {%- for n in graph.nodes.values() -%}
    {%- if n.resource_type == 'model' and (n.name | lower) == target_name -%}
      {%- do candidates.append(n) -%}
    {%- endif -%}
  {%- endfor -%}

  {%- if candidates | length == 0 -%}
    {{ exceptions.raise_compiler_error("Model '" ~ model ~ "' not found in project.") }}
  {%- endif -%}

  {%- set node = candidates[0] -%}

  {#--- Get the relation ---#}
  {%- set rel = adapter.get_relation(
        database = node.database or target.database,
        schema   = node.schema   or target.schema,
        identifier = node.alias  or node.name
     ) -%}

  {%- if not rel -%}
    {{ exceptions.raise_compiler_error("Table for model '" ~ model ~ "' not found. Run 'dbt run -s " ~ model ~ "' first.") }}
  {%- endif -%}

  {%- if rel.type != 'table' -%}
    {{ exceptions.raise_compiler_error("Model '" ~ model ~ "' is not materialized as a table (found: " ~ rel.type ~ ").") }}
  {%- endif -%}

  {#--- Build fully qualified table name ---#}
  {%- set fq = rel.database ~ '.' ~ rel.schema ~ '.' ~ rel.identifier -%}

  {#--- Column names ---#}
  {%- set col = column_name | upper -%}
  {%- set tmp_col = col ~ '_NUM' -%}

  {#--- Check if source column exists and get its current data type ---#}
  {%- set check_sql -%}
    select column_name, data_type
    from {{ rel.database }}.information_schema.columns
    where table_schema = '{{ rel.schema | upper }}'
      and table_name = '{{ rel.identifier | upper }}'
      and upper(column_name) = '{{ col }}'
  {%- endset -%}

  {%- set check_result = run_query(check_sql) -%}
  {%- if execute and (not check_result.rows or check_result.rows | length == 0) -%}
    {{ exceptions.raise_compiler_error("Column '" ~ column_name ~ "' not found in " ~ fq) }}
  {%- endif -%}

  {%- set old_type = 'unknown' -%}
  {%- if execute and check_result.rows and check_result.rows | length > 0 -%}
    {%- set old_type = check_result.rows[0][1] -%}
  {%- endif -%}

  {#--- Build the SQL statements ---#}
  {%- set sql_statements = [
      'ALTER TABLE ' ~ fq ~ ' ADD COLUMN ' ~ tmp_col ~ ' ' ~ new_type ~ ';',
      'UPDATE ' ~ fq ~ ' SET ' ~ tmp_col ~ ' = CAST(' ~ col ~ ' AS ' ~ new_type ~ ');',
      'ALTER TABLE ' ~ fq ~ ' DROP COLUMN ' ~ col ~ ';',
      'ALTER TABLE ' ~ fq ~ ' RENAME COLUMN ' ~ tmp_col ~ ' TO ' ~ col ~ ';'
    ] -%}

  {#--- Dry run: just log the SQL ---#}
  {%- if dry_run -%}
    {%- do log('', info=true) -%}
    {%- do log('=== DRY RUN: update_column_data_type ===', info=true) -%}
    {%- do log('Model: ' ~ model, info=true) -%}
    {%- do log('Table: ' ~ fq, info=true) -%}
    {%- do log('Column: ' ~ column_name, info=true) -%}
    {%- do log('Current type: ' ~ old_type, info=true) -%}
    {%- do log('New type: ' ~ new_type, info=true) -%}
    {%- do log('', info=true) -%}
    {%- do log('SQL to be executed:', info=true) -%}
    {%- for stmt in sql_statements -%}
      {%- do log(stmt, info=true) -%}
    {%- endfor -%}
    {%- do log('', info=true) -%}
    {%- do log('To execute, set dry_run=false', info=true) -%}
    {{ return('') }}
  {%- endif -%}

  {#--- Execute for real ---#}
  {%- do log('Executing column type change for ' ~ fq ~ '.' ~ column_name, info=true) -%}
  {%- do log('  Current type: ' ~ old_type, info=true) -%}
  {%- do log('  New type: ' ~ new_type, info=true) -%}

  {%- for stmt in sql_statements -%}
    {%- do log('Running: ' ~ stmt, info=true) -%}
    {%- do run_query(stmt) -%}
  {%- endfor -%}

  {%- do log('✓ Successfully changed ' ~ column_name ~ ' from ' ~ old_type ~ ' to ' ~ new_type ~ ' in ' ~ fq, info=true) -%}

  {{ return('') }}

{%- endmacro -%}
