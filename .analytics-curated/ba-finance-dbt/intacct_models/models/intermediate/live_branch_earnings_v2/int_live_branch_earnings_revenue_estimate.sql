with days_on_rent_cte as (
    select
        r.rental_id,
        rs.rental_status_id,
        rs.name as rental_status,
        datediff(hour, r.start_date, r.end_date) / 24 as days_on_rent
    from {{ ref("stg_es_warehouse_public__rentals") }} as r
        inner join {{ ref("stg_es_warehouse_public__rental_statuses") }} as rs
            on r.rental_status_id = rs.rental_status_id
    where
        rs.rental_status_id != 8
        and r.start_date < dateadd(month, -6, current_timestamp)
),

rental_end_estimate as (
    select
        greatest(ceil(dorc.days_on_rent), 1) as days_on_rent,
        count(*) / sum(count(dorc.days_on_rent)) over () as percent_chance_rental_will_end
    from days_on_rent_cte as dorc
    group by days_on_rent
),

get_all_potential_rentals as (
    select
        r.rental_id,
        r.start_date,
        r.end_date,
        r.price_per_day,
        r.price_per_week,
        r.price_per_month,
        i.invoice_id,
        i.start_date as invoice_start_date,
        i.end_date as invoice_end_date,
        coalesce(i.end_date, r.start_date) as bill_start,
        -- Might need to add one day
        datediff(day, bill_start, last_day(current_timestamp)) as potential_days_on_rent,
        greatest(0, datediff(day, bill_start, current_timestamp)) as minimum_days_on_rent,
        case when potential_days_on_rent > 28 then potential_days_on_rent - 28 end as extra_days,
        case
            when potential_days_on_rent >= 28 and i.invoice_id is not null
                then r.price_per_month -- Rental that has been on rent for multiple cycles
            when potential_days_on_rent >= 18 and i.invoice_id is null
                then r.price_per_month -- First invoice for a rental
        end as estimated_revenue,
        row_number() over (partition by r.rental_id order by bill_start desc) as invoice_order
    from {{ ref("stg_es_warehouse_public__orders") }} as o
        inner join {{ ref("stg_es_warehouse_public__rentals") }} as r
            on o.order_id = r.order_id
        left join {{ ref("stg_es_warehouse_public__invoices") }} as i
            on o.order_id = i.order_id
    where
        r.rental_status_id in (5, 6, 7)
        and r.rental_type_id = 1 -- using standard rentals only
        and bill_start >= dateadd(day, -60, current_timestamp) -- remove junk rentals
    qualify
        invoice_order = 1
),

get_estimated_rental_value as (
    select
        gapr.rental_id,
        -- this calc is very basic and can be improved
        sum(case
            when gapr.price_per_day is not null
                and gapr.price_per_week is null
                and gapr.price_per_month is null
                then gapr.price_per_day * coalesce(gapr.extra_days, ree.days_on_rent)
            when gapr.price_per_month is not null
                and gapr.price_per_week is null
                and gapr.price_per_day is null then gapr.price_per_month
            when ree.days_on_rent <= 2
                then gapr.price_per_day * coalesce(gapr.extra_days, ree.days_on_rent)
            when ree.days_on_rent <= 14
                then gapr.price_per_week * ceil(coalesce(gapr.extra_days, ree.days_on_rent) / 7)
            else gapr.price_per_month
        end
        * ree.percent_chance_rental_will_end) as price_estimate
    from get_all_potential_rentals as gapr
        inner join rental_end_estimate as ree
            on gapr.minimum_days_on_rent <= ree.days_on_rent
                and gapr.potential_days_on_rent >= ree.days_on_rent
    group by gapr.rental_id
),

invoices_to_cycle_output as (
    select
        'Invoices to Cycle' as source,
        gapr.rental_id,
        sum(
            case
                when gapr.extra_days is null then coalesce(gapr.estimated_revenue, gerv.price_estimate) * 0.98 else
                    (gapr.estimated_revenue + gerv.price_estimate) * 0.98
            end
        ) as amount
    from get_all_potential_rentals as gapr
        inner join get_estimated_rental_value as gerv
            on gapr.rental_id = gerv.rental_id
    group by gapr.rental_id
),

avg_rates as (
    select
        avg(r.price_per_day) as avg_price_per_day,
        avg(r.price_per_week) as avg_price_per_week,
        avg(r.price_per_month) as avg_price_per_month
    from {{ ref("stg_es_warehouse_public__rentals") }} as r
    where
        r.rental_type_id = 1
        and r.price_per_day is not null
        and r.price_per_week is not null
        and r.price_per_month is not null
        and r.start_date >= dateadd(day, -180, current_timestamp)
),

day_of_week_rentals as (
    select
        dayofweek(r.start_date) as day_of_week,
        count(r.rental_id) / 26 as rentals_per_day
    from {{ ref("stg_es_warehouse_public__rentals") }} as r
    where
        r.start_date >= dateadd(
            week, -26, current_date()
            - mod(dayofweek(current_date()), 7)
        )
    group by day_of_week
),

date_series as (
    select
        datediff(day, series, last_day(current_timestamp)) as days_left_in_month,
        dayofweek(series) as day_of_week
    from
        table(
            es_warehouse.public.generate_series(
                current_timestamp::date::timestamp_tz,
                last_day(current_timestamp)::timestamp_tz,
                'day'
            )
        )
),

out as (
    select
        'Projected New Rentals' as source,
        null as rental_id,
        sum(case
            when ar.avg_price_per_day is not null
                and ar.avg_price_per_week is null
                and ar.avg_price_per_month is null
                then ar.avg_price_per_day * ree.days_on_rent
            when ar.avg_price_per_month is not null
                and ar.avg_price_per_week is null
                and ar.avg_price_per_day is null then ar.avg_price_per_month
            when ree.days_on_rent <= 2
                then ar.avg_price_per_day * ree.days_on_rent
            when ree.days_on_rent <= 14
                then ar.avg_price_per_week * ceil(ree.days_on_rent / 7)
            else ar.avg_price_per_month
        end
        * ree.percent_chance_rental_will_end * dowr.rentals_per_day * 0.98) as amount
    from date_series as ds
        inner join day_of_week_rentals as dowr
            on ds.day_of_week = dowr.day_of_week
        inner join rental_end_estimate as ree
            on ds.days_left_in_month >= ree.days_on_rent,
        avg_rates as ar

    union all

    select
        itco.source,
        itco.rental_id,
        itco.amount
    from
        invoices_to_cycle_output as itco

    --------------------------------------------------------------------------------------------------------------------
    -- Rentals that have billed in the current month
    --------------------------------------------------------------------------------------------------------------------
    union all

    select
        'Approved Invoices' as source,
        li.rental_id,
        sum(li.amount) as amount
    from {{ ref("stg_es_warehouse_public__invoices") }} as i
        inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on i.invoice_id = li.invoice_id
    where
        li.line_item_type_id = 8
        and date_trunc(month, i.billing_approved_date) = date_trunc(month, current_timestamp)
    group by li.rental_id

    --------------------------------------------------------------------------------------------------------------------
    -- Invoices that need to be approved
    --------------------------------------------------------------------------------------------------------------------
    union all

    select
        'Invoices to be Approved' as source,
        li.rental_id,
        sum(li.amount) * 0.98 as amount -- 98% of invoices created in a month get approved in that month
    from {{ ref("stg_es_warehouse_public__invoices") }} as i
        inner join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on i.invoice_id = li.invoice_id
    where
        li.line_item_type_id = 8
        and date_trunc(month, i.date_created) = date_trunc(month, current_timestamp)
        and i.billing_approved = false
    group by li.rental_id
)

select round(sum(amount), 0) as amount
from out
