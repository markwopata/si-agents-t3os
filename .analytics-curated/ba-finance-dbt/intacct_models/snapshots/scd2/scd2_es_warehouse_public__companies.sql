{% snapshot scd2_es_warehouse_public__companies %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="company_id",
        strategy="timestamp",
        updated_at="_es_update_timestamp",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'companies') }}

{% endsnapshot %}
