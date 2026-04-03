{% snapshot transfer_orders_snapshot %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="transfer_order_id",
        strategy='timestamp',
        updated_at='_es_update_timestamp',
        invalidate_hard_deletes=True
    )
}}

select
    *
from {{ source('asset_transfer_public', 'transfer_orders') }}

{% endsnapshot %}
