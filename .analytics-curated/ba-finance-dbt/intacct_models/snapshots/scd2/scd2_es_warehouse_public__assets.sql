{% snapshot scd2_es_warehouse_public__assets %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="asset_id",
        strategy="timestamp",
        updated_at="date_updated",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'assets') }}
{% endsnapshot %}
