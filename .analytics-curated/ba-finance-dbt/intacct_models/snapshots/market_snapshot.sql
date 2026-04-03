{% snapshot market_snapshot %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="child_market_id",
        strategy='timestamp',
        updated_at='date_updated',
        invalidate_hard_deletes=True
    )
}}

select * from {{ ref('market') }}

{% endsnapshot %}