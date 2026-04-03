{#--
    Macro: remove_duplicate_records_in_snapshot

    Description:
        This macro cleans up a dbt snapshot table that somehow has duplicate dbt_scd_id when we should expect unique dbt_scd_id.

    Args:
        model (str): The name of the snapshot model to inspect (typically a ref() string, like 'stg_table').
        dry_run (bool): false if we want to override the table; true if we are just testing

    Returns:
        Nothing. 
        If dry_run is set to true, it will only print out the before and after record count.
        If dry_run is false, it'll override the target snapshot table 

    Usage:
        dbt run-operation remove_duplicate_records_in_snapshot --args '{   "model": "stg_t3__telematics_health_snapshot" , "dry_run": true}'
--#}


{%- macro remove_duplicate_records_in_snapshot(model, dry_run=true) -%} 

    -- check that the model is from snapshot schema
    {%- set rel = ref(model | lower) -%}
    {%- set actual_schema = (rel.schema or '') | upper -%}
    {%- if actual_schema != 'SNAPSHOTS' -%}
    {{ exceptions.raise_compiler_error(
        "Expected schema 'SNAPSHOTS' but got '" ~ actual_schema ~ "' for " ~ rel
    ) }}
    {%- endif %}

   {%- set sql -%}
    SELECT {{ get_columns_except(model) }} 
    FROM (
      SELECT *
             , ROW_NUMBER() OVER (
               PARTITION BY dbt_scd_id
               ORDER BY
                 CASE WHEN (dbt_valid_to IS NULL OR dbt_valid_to = TO_DATE('9999-12-31')) THEN 1 ELSE 0 END DESC,
                 dbt_valid_from DESC,
                 dbt_updated_at DESC
             ) AS rn
      FROM {{ ref(model) }}
    ) t
    WHERE 
        -- keep only one open row per id
        (dbt_valid_to is null or to_date(dbt_valid_to) = '9999-12-31' and rn = 1)
        -- plus ALL closed rows
        or (dbt_valid_to is not null and to_date(dbt_valid_to) <> '9999-12-31')
    {% endset %}

    {%- set before_change %} SELECT COUNT(*) AS record_count FROM ( {{ ref(model) }} ){%- endset -%}
    {%- set before_change_res = run_query(before_change) -%} 

    {# Only replace table if dry_run = false #}
    {%- if not dry_run -%}
        {# Replace the table in place with the output #}
        {{ log("Replacing table " ~ model ~ " with deduplicated result...", info=True) }}
        {%- set replace_sql -%} CREATE OR REPLACE TABLE {{ ref(model) }} AS {{ sql }}{%- endset -%}
        {% do run_query(replace_sql) -%}
    {%- endif -%}

    {%- set after_change %}SELECT COUNT(*) AS record_count FROM ( {{ sql }} ){%- endset -%}
    {%- set after_change_res = run_query(after_change) -%}
    {%- if before_change_res and before_change_res.rows -%}
    {{ log("Before macro run: row count = " ~ before_change_res.rows[0][0], info=True) }}
    {{ log("After macro run: new row count = " ~ after_change_res.rows[0][0], info=True) }}
    {%- else -%}
    {{ log("Dry run: unable to fetch count (no result rows returned).", info=True) }}
    {%- endif -%}

{%- endmacro -%}
