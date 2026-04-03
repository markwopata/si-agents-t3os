{%- macro sync_migrated_heap_users() -%}

{%- if model_exists() is not none -%}
    {{ log("Running macro sync_migrated_heap_users on " ~ this, info=true) }}

    MERGE INTO {{ this }} tgt
    USING {{ ref("stg_heap__user_migrations") }} migration
    ON tgt.heap_user_id = migration.from_user_id
    WHEN MATCHED THEN
    UPDATE SET
        tgt.heap_user_id = migration.to_user_id,
        tgt._dbt_updated_timestamp = migration._dbt_updated_timestamp
{%- else -%}
    {%- do log("Table: " ~ this ~ " does not exist. Skipping merge pre-hook", info=True) -%}
{%- endif -%}

{%- endmacro -%}