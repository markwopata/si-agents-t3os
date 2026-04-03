with rental_timeline as (

    select * from {{ ref('int_vsg_hq_rental_payments_timeline') }}

),

stripe_charges as (

    select * from {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }}
    where receipt_url is not null

),

stripe_refunds as (

    select * from {{ ref('dim_hq_rentals_refunds') }}

),

es_company_directory as (

    select * from {{ ref('stg_analytics_payroll__company_directory') }}
    qualify row_number() over (partition by work_email order by position_effective_date desc) = 1

),

charges_by_day as (

    select
        reservation_id,
        metadata__email as email,
        is_active_employee,
        date_trunc(day, payment_charge_created_at)::date as charge_date,
        sum(case when description ilike '%deposit%' then amount else 0 end) as deposit_amount,
        sum(case when description ilike '%deposit%' then 0 else amount end) as paid_amount,
    from stripe_charges
    left join es_company_directory cd
        on metadata__email = cd.work_email
    group by
        all

),

stripe_taxes as (

    select *
    from {{ ref('stg_analytics_stripe_vehicle_solutions__charge') }}
    where receipt_url is not null
        and description not ilike '%deposit%'
    qualify row_number()
            over (
                partition by reservation_id::int, date_trunc(day, payment_charge_created_at)
                order by payment_charge_created_at desc
            )
        = 1

),

add_payments as (
    select
        r.reservation_id,
        r.market_id,
        r.market_name,
        r.city,
        r.rental_date,
        r.earliest_charge_date,
        r.pick_up_date,
        case
            when date_trunc('day', r.pick_up_date) = rental_date then 'Pick Up Date'
            when date_trunc('day', r.return_date) = rental_date then 'Return Date'
            when paid_amount is not null then 'Payment Date'
            when refunds.total_refund_amount is not null then 'Refund Date'
        end as event,
        case
            when r.earliest_charge_date < r.pick_up_date then 'Prepaid'
            when r.earliest_charge_date > r.return_date then 'Postpaid'
            else 'Paid Throughout Rental'
        end as payment_timing_type,
        r.is_month_end,
        coalesce(c.paid_amount, 0) as paid_amount,
        coalesce(c.deposit_amount, 0) as deposit_amount,
        coalesce(refunds.total_refund_amount, 0) as refunded_amount,
        c.email,
        c.is_active_employee,
        r.total_revenue,
        r.rental_duration,
        tax.metadata__total_taxes,
        coalesce(
            last_value(tax.metadata__total_taxes)
            ignore nulls
                over (
                    partition by r.reservation_id
                    order by r.rental_date
                    rows between unbounded preceding and 1 preceding
                ), 0
        ) as prior_day_total_taxes,
        tax.metadata__total_taxes - prior_day_total_taxes as sales_tax,
        case
            when r.rental_date < date_trunc('day', r.pick_up_date) then 0
            when r.rental_date > date_trunc('day', r.return_date) then 0   -- optional guard
            else r.total_revenue / nullif(r.rental_duration, 0)
        end as daily_revenue,
        sum(
            daily_revenue
        ) over (
            partition by r.reservation_id
            order by r.rental_date
            rows between unbounded preceding and current row
        ) as cumulative_revenue,
        coalesce(
            sum(c.paid_amount)
                over (partition by r.reservation_id order by r.rental_date rows between unbounded preceding and current row),
            0
        ) as cumulative_paid

    from rental_timeline as r
        left join charges_by_day as c
            on r.reservation_id = c.reservation_id
                and r.rental_date = c.charge_date
        left join stripe_taxes as tax
            on r.reservation_id = tax.reservation_id::int
                and r.rental_date = date_trunc(day, tax.payment_charge_created_at)::date
        left join stripe_refunds refunds
            on refunds.reservation_id = r.reservation_id
            and refunds.refund_date = r.rental_date
)

select
    reservation_id,
    market_id,
    market_name,
    city,
    rental_date,
    earliest_charge_date,
    pick_up_date,
    payment_timing_type,
    event,
    is_month_end,
    paid_amount,
    sales_tax,
    sum(
        sales_tax
    ) over (
        partition by reservation_id
        order by rental_date
        rows between unbounded preceding and current row
    ) as cumulative_sales_tax,
    cumulative_paid - cumulative_sales_tax as cumulative_paid,
    deposit_amount,
    refunded_amount,
    email,
    is_active_employee,
    total_revenue,
    rental_duration,
    daily_revenue,
    cumulative_revenue,
    coalesce(cumulative_paid - cumulative_sales_tax - cumulative_revenue, 0) as delta_month_to_date,
    iff(delta_month_to_date > 0, delta_month_to_date, 0) as deferred_revenue,
    iff(delta_month_to_date < 0, delta_month_to_date, 0) as unbilled_revenue
from add_payments
order by reservation_id asc, rental_date asc
