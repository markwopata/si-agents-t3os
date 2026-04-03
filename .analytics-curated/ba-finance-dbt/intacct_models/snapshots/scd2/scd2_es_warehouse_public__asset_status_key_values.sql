{% snapshot scd2_es_warehouse_public__asset_status_key_values %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="asset_status_key_value_id",
        strategy="timestamp",
        updated_at="updated",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'asset_status_key_values') }}

{% endsnapshot %}
