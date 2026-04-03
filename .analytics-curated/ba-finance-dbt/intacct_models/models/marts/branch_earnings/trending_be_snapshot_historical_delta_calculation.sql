with snapshot_differences as (
    {{ live_be_snapshot_delta(ref('int_live_branch_earnings_looker_snapshot'), 'timestamp') }}
)

, grain_summation as (
    select
        pk_id
        , latest_timestamp
        , previous_timestamp
        , coalesce(sum(amount_in_latest), 0) - coalesce(sum(amount_in_previous), 0) as delta
    from snapshot_differences
    group by
        all
)

select * from grain_summation
{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  -- (uses >= to include records arriving later on the same day as the last run of this model)
  where latest_timestamp >= (select coalesce(max(latest_timestamp), '1900-01-01') from {{ this }})

{% endif %}
