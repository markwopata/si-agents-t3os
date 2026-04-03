with rental_timeline as (

    select * from {{ ref('int_vsg_turo_rentals_timeline') }}

)

, charges_by_day as (

    select * from {{ ref('int_vsg_turo_rentals_earnings_aggregation') }}

)

, add_payments as (
select
    r.reservation_id,
    r.market_id,
    r.market_name,
    r.vin,
    r.license_plate_number,
    r.rental_date,
    r.earliest_charge_date,
    r.trip_start,
    r.trip_end,
    case
        when date_trunc('day', r.trip_start) = rental_date and date_trunc('day', r.trip_end) = rental_date then 'Pick Up / Return Date'
        when date_trunc('day', r.trip_start) = rental_date then 'Pick Up Date'
        when date_trunc('day', r.trip_end) = rental_date then 'Return Date'
        when c.trip_earnings_amount is not null then 'Payment Date'
    end as event,
        case
            when r.earliest_charge_date < r.trip_start then 'Prepaid'
            when r.earliest_charge_date > r.trip_end then 'Postpaid'
            else 'Paid Throughout Rental'
        end as payment_timing_type,
    r.is_month_end,
    coalesce(c.trip_earnings_amount, 0) as trip_earnings_amount,
        coalesce(
            sum(c.trip_earnings_amount)
                over (partition by r.reservation_id order by r.rental_date rows between unbounded preceding and current row),
            0
        ) as cumulative_paid,
    r.total_earnings,
    case
        when r.rental_date <= date_trunc('day', r.trip_start) then 0
        when r.rental_date > date_trunc('day', r.trip_end) then 0   -- optional guard
        else r.total_earnings / nullif(r.trip_days, 0)
    end as daily_revenue,
    sum(
        daily_revenue
    ) over (
        partition by r.reservation_id
        order by r.rental_date
        rows between unbounded preceding and current row
    ) as cumulative_revenue
from rental_timeline as r
left join charges_by_day as c
    on r.reservation_id = c.reservation_id
    and r.rental_date = c.earning_date
)

select
    r.reservation_id,
    r.market_id,
    r.market_name,
    r.vin,
    r.license_plate_number,
    r.rental_date,
    r.earliest_charge_date,
    r.trip_start,
    r.trip_end,
    r.event,
    r.payment_timing_type,
    r.is_month_end,
    r.trip_earnings_amount,
    r.cumulative_paid,
    r.total_earnings,
    r.daily_revenue,
    sum(
        r.daily_revenue
    ) over (
        partition by r.reservation_id
        order by r.rental_date
        rows between unbounded preceding and current row
    ) as cumulative_revenue,
    round(coalesce(cumulative_paid - cumulative_revenue, 0), 2) as delta_month_to_date,
    iff(delta_month_to_date > 0, delta_month_to_date, 0) as deferred_revenue,
    iff(delta_month_to_date < 0, delta_month_to_date, 0) as unbilled_revenue
from add_payments as r
order by r.reservation_id asc, r.rental_date asc