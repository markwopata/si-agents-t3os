with market_snapshot as (

    select distinct
        child_market_id,
        region,
        date_updated
    from {{ ref('market_snapshot') }}

),

pk_details as (
    select
        d.pk_id,
        coalesce(l.transaction_number, p.transaction_number) as transaction_number,
        coalesce(l.filter_month, p.filter_month) as filter_month,
        coalesce(l.description, p.description) as description,
        coalesce(l.transaction_number_format, p.transaction_number_format) as transaction_number_format,
        m.region,
        coalesce(l.market_id, p.market_id) as market_id,
        coalesce(l.source_model, p.source_model) as source_model,
        coalesce(l.timestamp, p.timestamp) as timestamp,
        coalesce(l.dbt_valid_to, p.dbt_valid_to) as dbt_valid_to,
        coalesce(
            l.snapshot_day, to_char(convert_timezone('UTC', 'America/Los_Angeles', d.latest_timestamp), 'YYYY-MM-DD')
        ) as snapshot_day,
        d.delta,
        m.date_updated
    from {{ ref('trending_be_snapshot_historical_delta_calculation') }} as d

    -- first, join on latest_timestamp
        left join {{ ref('int_live_branch_earnings_looker_snapshot') }} as l
            on d.pk_id = l.pk_id
                and d.latest_timestamp = l.timestamp

        -- then, join on previous_timestamp as a fallback if latest_timestamp doesn't match
        left join {{ ref('int_live_branch_earnings_looker_snapshot') }} as p
            on d.pk_id = p.pk_id
                and d.previous_timestamp = p.timestamp

        -- bring in region and district from the markets snapshot table since we most recently added those fields to the snapshot
        -- want the market_snapshot table because it contians historical market data
        left join market_snapshot as m
            on coalesce(l.market_id, p.market_id) = m.child_market_id
                -- add date component to join
                and m.date_updated::date
                = coalesce(
                    l.snapshot_day,
                    to_char(convert_timezone('UTC', 'America/Los_Angeles', d.latest_timestamp), 'YYYY-MM-DD')
                )

    -- in the market snapshot table, there are multiple runs within a day, so picking the latest one
    qualify row_number()
            over (
                partition by
                    d.pk_id,
                    coalesce(l.market_id, p.market_id),
                    coalesce(
                        l.snapshot_day,
                        to_char(convert_timezone('UTC', 'America/Los_Angeles', d.latest_timestamp), 'YYYY-MM-DD')
                    )
                order by date_updated desc
            )
        = 1
)

select * from pk_details
{% if is_incremental() %}

    -- this filter will only be applied on an incremental run
    -- (uses >= to include records arriving later on the same day as the last run of this model)
    where timestamp >= (select max(timestamp) from {{ this }})

{% endif %}
