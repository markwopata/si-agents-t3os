{% snapshot scd2_es_warehouse_public__billing_company_preferences %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="billing_company_preferences_id",
        strategy="timestamp",
        updated_at="date_updated",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'billing_company_preferences') }}

{% endsnapshot %}
