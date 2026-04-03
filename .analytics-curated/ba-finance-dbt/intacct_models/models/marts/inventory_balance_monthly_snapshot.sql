{{ 
    config(
        materialized='incremental',
        on_schema_change='append_new_columns'
    )
}}

with latest_snapshot as (
    select
        max(timestamp) as max_timestamp,
        max(period_start_date) as max_period_start_date
    from
        {{ source('analytics_intacct_models', 'inventory_balance_monthly_snapshot') }}
),

current_data as (
    select *
    from
        {{ ref('inventory_balance') }} as ibt
        inner join latest_snapshot as ls
    where
        -- Don't capture if we've already captured this month end. This also ensures the first run will capture the month end. If it failed for some reason, next run picks it up.
        max_period_start_date
        != date_trunc(month, add_months(convert_timezone('UTC', 'America/Chicago', current_timestamp()), -1))::date
)

select *
from
    current_data
