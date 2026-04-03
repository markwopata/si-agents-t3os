{% snapshot int_live_branch_earnings_looker_snapshot %}

{{
    config(
        target_database=generate_database_name(),
        unique_key="pk_id",
        strategy='timestamp',
        updated_at='timestamp',
        invalidate_hard_deletes=True
    )
}}
with initial_snapshot as (
    select
        md5(concat(
            coalesce(transaction_number, ''), '-', 
            filter_month, '-', 
            coalesce(description, ''), '-', 
            coalesce(transaction_number_format, ''), '-', 
            coalesce(market_id, 0), '-', 
            coalesce(source_model, '')
        )) as pk_id,
        transaction_number,
        region,
        district,
        description,
        filter_month,
        transaction_number_format,
        market_id,
        source_model,
        amount,
        timestamp
    from {{ ref('int_live_branch_earnings_looker') }}
)

select
    pk_id
    , transaction_number
    , description
    , filter_month
    , transaction_number_format
    , market_id
    , source_model
    , timestamp
    , region
    , district
    , to_char(convert_timezone('UTC', 'America/Los_Angeles', timestamp), 'YYYY-MM-DD') as snapshot_day
    , sum(amount) as amount
from initial_snapshot
group by 
    all

{% endsnapshot %}
