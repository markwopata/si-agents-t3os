{#--
    Macro: rename_table_to_model

    Description:
        This macro updates the table's name to match the model in dbt.

    Args:
        model (str): The name of the model (typically a ref() string, like 'stg_table'). This should match the dbt model's name,
        previous_name (str): THe previous name of the model / table.
        dry_run (bool): false if we want to override the table; true if we are just testing

    Returns:
        Nothing. 
        If dry_run is set to true, it will only print out the before and after record count.
        If dry_run is false, it'll override the target snapshot table 

    Usage:
        I deployed a change in dbt, updating the models from stg_t3__telematics_health_snapshot to stg_t3__telematics_health_snapshot_daily.
        stg_t3__telematics_health_snapshot already exists and I want to retain what's in there. I want stg_t3__telematics_health_snapshot_daily to build into
        stg_t3__telematics_health_snapshot and need to realign the names between what's currently in the database vs what DBT expects to find.
        dbt run-operation rename_table_to_model --args '{ "model": "stg_t3__telematics_health_snapshot_daily", "previous_name": "stg_t3__telematics_health_snapshot", "dry_run": true}'
--#}

{%- macro rename_table_to_model(previous_name=None, model=None, dry_run=True) -%}

    {%- set rel = ref(model | lower) -%}

    {# Check if table_in_db table exists #}
    {%- set table_in_db = adapter.get_relation(database=rel.database, schema=rel.schema, identifier=previous_name) -%}
    {%- if not table_in_db -%}
        {{ log("Table not found: " ~ rel, info=True) }}
        {{ log("table_in_db database: " ~ rel.database, info=True) }}
        {{ log("table_in_db schema: " ~ rel.schema, info=True) }}
        {{ log("table_in_db table name: " ~ previous_name, info=True) }}
        {{ return(none) }}
    {%- endif -%}

    {# Only allow tables to be renamed#}
    {%- if table_in_db.type and table_in_db.type | lower != 'table' -%}
        {{ log("Name passed in '" ~ table_in_db ~ "' is type '" ~ table_in_db.type ~ "'. Only TABLE supports RENAME.", info=True) }}
        {{ return(none) }}
    {%- endif -%}

    {# Target (new) relation must not exist #}
    {%- set target = api.Relation.create(database=rel.database, schema=rel.schema, identifier=rel.identifier) -%}
    {%- if adapter.get_relation(database=target.database, schema=target.schema, identifier=target.identifier) -%}
        {{ log("Target already exists: " ~ target ~ " — aborting.", info=True) }}
        {{ return(none) }}
    {%- endif -%}

    {{ log("Will rename " ~ ((table_in_db ~ '') | lower) ~ " -> " ~ ((target ~ '') | lower), info=True) }}

    {%- if dry_run -%}
        {{ log("DRY RUN only. Set dry_run=false to execute.", info=True) }}
        {{ return(none) }}
    {%- endif -%}

    {# Execute the rename (same schema). Snowflake syntax: ALTER TABLE <db>.<schema>.<old> RENAME TO <new> #}
    {%- set sql -%} alter table {{ table_in_db }} rename to {{ target }} {%- endset -%} 
    {%- do run_query(sql) -%}
    {{ log("Renamed " ~ ((table_in_db ~ '') | lower) ~ " -> " ~ ((target ~ '') | lower) , info=True) }}

{%- endmacro -%}
