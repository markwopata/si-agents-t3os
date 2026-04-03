with turo_rentals as (

    select * from {{ ref('int_vsg_turo_rentals') }}

),

turo_payments as (

    select
        reservation_id,
        min(earning_date) as earliest_charge_date,
        max(earning_date) as latest_charge_date
    from {{ ref('stg_analytics_vehicle_solutions__turo_earnings') }}
    group by
        all
),

charge_and_rental_timeline as (
    select
        t.reservation_id,
        t.market_id,
        t.market_name,
        t.vin,
        t.license_plate_number,
        t.trip_start,
        t.trip_end,
        t.trip_days,
        t.total_earnings,
        p.earliest_charge_date,
        p.latest_charge_date,
        least_ignore_nulls(t.trip_start, p.earliest_charge_date) as rental_start,
        p.earliest_charge_date is not null as has_payment_activity,
    from turo_rentals as t
        left join turo_payments as p
            on t.reservation_id = p.reservation_id

),

full_date_timeline as (

    select
        t.reservation_id,
        t.market_id,
        t.market_name,
        t.vin,
        t.license_plate_number,
        series::date as rental_date,
        t.total_earnings,
        t.rental_start,
        t.trip_start,
        t.trip_end,
        t.trip_days,
        t.has_payment_activity,
        t.earliest_charge_date,
    from charge_and_rental_timeline as t
        cross join
            table(
                es_warehouse.public.generate_series(
                    date_trunc(day, t.rental_start)::timestamp_tz,
                    date_trunc(day, t.trip_end)::timestamp_tz,
                    'day'
                )
            )

)

select
    *,
    coalesce(rental_date = last_day(rental_date), false) as is_month_end
from full_date_timeline
order by reservation_id asc, rental_date asc
