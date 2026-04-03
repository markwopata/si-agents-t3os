{% snapshot scd2_es_warehouse_public__company_purchase_order_line_items %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="company_purchase_order_line_item_id",
        strategy="timestamp",
        updated_at="_es_update_timestamp",
        invalidate_hard_deletes=True
    )
}}

    select *
    from {{ source('es_warehouse_public', 'company_purchase_order_line_items') }}

{% endsnapshot %}
