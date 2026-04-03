{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['asset_id', 'current_start', 'failure_logged_at'],
    schema = 'dbt_test__audit',
) }}

with ordered_ranges as (
    select
        asset_id,
        date_start,
        date_end,
        row_number() over (
            partition by asset_id
            order by
                date_start

        ) as rn
    from {{ ref('int_payout_programs') }}
    -- exclude records where start and end dates are the same for this test.
    where date_start != date_end
),

overlapping_records as (
    select

        orc.asset_id,
        orc.date_start as current_start,
        orc.date_end as current_end,
        orp.date_start as previous_start,
        orp.date_end as previous_end
    from ordered_ranges as orc
        left join ordered_ranges as orp
            on

                orc.asset_id = orp.asset_id

                and orc.rn = orp.rn + 1
    where orp.date_end > orc.date_start
)

select
    *,
    current_timestamp as failure_logged_at
from overlapping_records
