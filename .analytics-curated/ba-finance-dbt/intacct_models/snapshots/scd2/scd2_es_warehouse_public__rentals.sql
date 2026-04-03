{% snapshot scd2_es_warehouse_public__rentals %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="rental_id",
        strategy="timestamp",
        updated_at="_es_update_timestamp",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'rentals') }}

{% endsnapshot %}
