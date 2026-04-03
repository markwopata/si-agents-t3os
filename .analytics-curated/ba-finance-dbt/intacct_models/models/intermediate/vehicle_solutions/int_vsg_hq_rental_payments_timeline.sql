with hq_reservations as (

    select * from {{ ref('stg_analytics_vehicle_solutions__hq_rental_reservations') }}
    qualify row_number() over (partition by reservation_id::int order by pick_up_date desc) = 1

),

stripe_charges as (

    select * from {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }}
    qualify row_number() over (partition by reservation_id::int order by payment_charge_created_at desc) = 1

),

hq_locations as (

    select * from {{ ref('stg_analytics_vsg_postgres__public__locations') }}

),

vsg_branch_mapping as (

    select * from {{ ref('seed_vsg_turo_to_branch_mapping')}}
    
),

charge_and_rental_timeline as (

    select  
        r.reservation_id,
        m.market_id,
        m.market_name,
        l.city,
        r.rental_duration,
        r.total_revenue,
        c.earliest_charge_date,
        c.latest_charge_date,
        r.pick_up_date,
        r.return_date,
        least_ignore_nulls(r.pick_up_date, c.earliest_charge_date) as rental_start,
        r.return_date as rental_end
    from hq_reservations as r
        left join stripe_charges as c
            on r.reservation_id = c.reservation_id
    left join hq_locations l
        on r.pick_up_location_id = l.hq_id
    left join vsg_branch_mapping m
        on l.region_id = m.vsg_region_id
        and m.turo_account_short_code != 'AZ' -- excluding 1 of the 2 codes for AZ "Phoenix, AZ - Vehicle Solutions" to avoid fan-out


),

full_date_timeline as (

    select
        t.reservation_id,
        series::date as rental_date,
        t.market_id,
        t.market_name,
        t.city,
        t.total_revenue,
        t.pick_up_date,
        t.return_date,
        t.rental_duration,
        t.earliest_charge_date,
    from charge_and_rental_timeline as t
        cross join
            table(
                es_warehouse.public.generate_series(
                    date_trunc(day, t.rental_start)::timestamp_tz,
                    date_trunc(day, t.rental_end)::timestamp_tz,
                    'day'
                )
            )

)

select
    *,
    coalesce(rental_date = last_day(rental_date), false) as is_month_end,
from full_date_timeline
order by reservation_id, rental_date asc
