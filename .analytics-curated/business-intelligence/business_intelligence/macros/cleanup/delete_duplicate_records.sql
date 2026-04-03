{#--
    Macro: delete_duplicate_records

    Description:
        Deletes ALL copies of duplicate records from a model, identified by a primary key.
        Unlike the deduplicate pre-hook (which keeps one copy), this removes every instance
        of a duplicated key so the records can be cleanly reprocessed.
        Supports both single and composite primary keys.

    Args:
        model (str): The name of the model to clean (e.g. 'fact_safety_observation_details').
        primary_key (str | list): The column(s) to identify duplicates on.
                                  e.g. 'safety_observation_key'
                                  e.g. ['safety_observation_id', 'photo']
        dry_run (bool): If true, only logs the duplicate count without deleting. Defaults to true.

    Returns:
        Nothing.
        If dry_run is true, logs the number of affected primary keys and rows.
        If dry_run is false, deletes all copies of duplicated records.

    Usage (single key):
        dbt run-operation delete_duplicate_records --args '{"model": "fact_safety_observation_details", "primary_key": ["safety_observation_key"], "dry_run": true}'
--#}

{%- macro delete_duplicate_records(model, primary_key, dry_run=true) -%}

    {%- set rel = ref(model | lower) -%}

    {# Normalize primary_key to a list #}
    {%- if primary_key is string -%}
        {%- set key_cols = [primary_key] -%}
    {%- else -%}
        {%- set key_cols = primary_key -%}
    {%- endif -%}

    {%- set key_cols_csv = key_cols | join(', ') -%}

    {%- set join_parts = [] -%}
    {%- for col in key_cols -%}
        {%- do join_parts.append('t.' ~ col ~ ' = dupes.' ~ col) -%}
    {%- endfor -%}
    {%- set join_conditions = join_parts | join(' AND ') -%}

    {%- set find_dupes_query -%}
        SELECT COUNT(*) AS duplicate_keys, SUM(cnt) AS total_rows
        FROM (
            SELECT {{ key_cols_csv }}, COUNT(*) AS cnt
            FROM {{ rel }}
            GROUP BY {{ key_cols_csv }}
            HAVING COUNT(*) > 1
        )
    {%- endset -%}

    {%- set results = run_query(find_dupes_query) -%}
    {%- set duplicate_keys = results.rows[0][0] if results and results.rows else 0 -%}
    {%- set total_rows = results.rows[0][1] if results and results.rows else 0 -%}

    {%- if duplicate_keys == 0 -%}
        {{ log("No duplicates found on " ~ rel ~ " for key(s) '" ~ key_cols_csv ~ "'.", info=True) }}

    {%- elif dry_run -%}
        {{ log("DRY RUN: Found " ~ duplicate_keys ~ " duplicated key(s) (" ~ total_rows ~ " rows) on " ~ rel ~ " for key(s) '" ~ key_cols_csv ~ "'.", info=True) }}
        {{ log("DRY RUN: Re-run with dry_run=false to delete.", info=True) }}

    {%- else -%}
        {%- set delete_query -%}
            DELETE FROM {{ rel }} t
            USING (
                SELECT {{ key_cols_csv }}
                FROM {{ rel }}
                GROUP BY {{ key_cols_csv }}
                HAVING COUNT(*) > 1
            ) dupes
            WHERE {{ join_conditions }}
        {%- endset -%}

        {%- do run_query(delete_query) -%}
        {{ log("Deleted " ~ total_rows ~ " rows (" ~ duplicate_keys ~ " duplicated key(s)) from " ~ rel ~ ".", info=True) }}
    {%- endif -%}

{%- endmacro -%}
