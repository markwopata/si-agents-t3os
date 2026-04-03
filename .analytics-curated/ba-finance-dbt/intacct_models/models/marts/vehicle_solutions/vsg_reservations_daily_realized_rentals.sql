with reservation_snapshots as (

    select * from {{ ref('int_vsg_reservations_snapshot_enriched') }}
    qualify dense_rank() over(partition by reservation_id order by dbt_snapshot_date desc) = 1
    -- snapshots run hourly; select the most recent snapshot per reservation for each day

)

, grouping_reservations_daily as (
    select
        reservation_id,
        platform,
        dbt_snapshot_date,
        platform_id,
        pick_up_date,
        region_name,
        array_agg(distinct status) as list_of_statuses,
        case
            when array_contains('Canceled'::variant, list_of_statuses) then 0 -- if it's canceled, then it didn't happen (even if it was on rent)
            when array_contains('Returned'::variant, list_of_statuses) or array_contains('On Rent'::variant, list_of_statuses) then 1
            when pick_up_date >= current_date() and array_contains('Pending'::variant, list_of_statuses) then 1 -- if the pick up date is today or in the future and the status is pending, then count it as an "advanced booking"
            else 0
        end as rental_occurred,
    from reservation_snapshots
    where 1=1
    group by
        all
)

select
    *
    , sum(rental_occurred) over(partition by pick_up_date) as total_daily_realized_rentals
from grouping_reservations_daily
