with out as (
    select
        ild.line_item_id,
        ild.amount,
        ild.asset_id,
        -- Asset level detail is required for reimbursement studies
        aa.oec,
        aa.model,
        aa.category,
        aa.serial_number,
        r.equipment_class_id,
        aa.class as equipment_class,
        ild.invoice_id,
        ild.invoice_number,
        m.child_market_id,
        m.child_market_name,
        m.market_id,
        m.market_name,
        m.region_district as district,
        m.region,
        m.region_name,
        m.market_type, -- Filter out ITL for branch earnings
        -- We are not counting invoices that were approved for/when markets were <12 months old.
        datediff(
            month,
            date_trunc(month, m.branch_earnings_start_month),
            date_trunc(month, ild.billing_approved_date)
        ) + 1 > 12 as is_months_open_greater_than_twelve, -- Filter for branch earnings
        ild.primary_salesperson_id,
        u.full_name as salesperson,
        ild.billing_approved_date,
        ild.paid_date,
        date_trunc(month, ild.paid_date) as paid_period_start_date,
        ild.invoice_date_created,
        ild.company_id,
        ild.customer_name,
        (
            r.price_per_week is null
            and r.price_per_month is null
            and r.price_per_day is not null
        ) as daily_billing_flag,
        datediff(day, ild.invoice_cycle_start_date, ild.invoice_cycle_end_date) as cycle_bill_days,
        -- TODO - move rates back a model
        case
            when daily_billing_flag
                then ild.rental_price_per_day * cycle_bill_days
            else ild.rental_cheapest_period_hour_count
                * coalesce(ild.rental_price_per_hour::number, 0)
                + ild.rental_cheapest_period_day_count
                * coalesce(ild.rental_price_per_day::number, 0)
                + ild.rental_cheapest_period_week_count
                * coalesce(ild.rental_price_per_week::number, 0)
                + coalesce(ild.rental_cheapest_period_month_count,
                            ild.rental_cheapest_period_four_week_count)
                * coalesce(ild.rental_price_per_month::number, 
                            ild.rental_price_per_four_weeks::number, 0)
        end as actual_rate,
        case
            when ild.rental_price_per_four_weeks::number is not null then 'four_week'
            when ild.rental_price_per_month::number is not null then 'monthly'
            else null 
        end as billing_type,
        case
            when daily_billing_flag
                then (o.price_per_month / 28) -- TODO cycle problem
                    * cycle_bill_days
            when billing_type = 'four_week' then
                  ild.rental_cheapest_period_hour_count * o.price_per_hour
                + ild.rental_cheapest_period_day_count * o.price_per_day
                + ild.rental_cheapest_period_week_count * o.price_per_week
                + ild.rental_cheapest_period_four_week_count * o.price_per_month
            when billing_type = 'monthly' then iff(cycle_bill_days > 28,(o.price_per_month / 28) * cycle_bill_days,
                  ild.rental_cheapest_period_hour_count * o.price_per_hour
                + ild.rental_cheapest_period_day_count * o.price_per_day
                + ild.rental_cheapest_period_week_count * o.price_per_week
                + ild.rental_cheapest_period_month_count * o.price_per_month)
        end as book_rate, -- previously called online rate
        case
            when daily_billing_flag
                then (b.price_per_month / 28)
                    * cycle_bill_days
            when billing_type = 'four_week' then 
                  ild.rental_cheapest_period_hour_count * b.price_per_hour
                + ild.rental_cheapest_period_day_count * b.price_per_day
                + ild.rental_cheapest_period_week_count * b.price_per_week
                + ild.rental_cheapest_period_four_week_count * b.price_per_month
            when billing_type = 'monthly' then iff(cycle_bill_days > 28,(b.price_per_month / 28) * cycle_bill_days,
                  ild.rental_cheapest_period_hour_count * b.price_per_hour
                + ild.rental_cheapest_period_day_count * b.price_per_day
                + ild.rental_cheapest_period_week_count * b.price_per_week
                + ild.rental_cheapest_period_month_count * b.price_per_month)
        end as benchmark_rate,
        case
            when daily_billing_flag
                then (f.price_per_month / 28)
                    * cycle_bill_days
            when billing_type = 'four_week' then 
                  ild.rental_cheapest_period_hour_count * f.price_per_hour
                + ild.rental_cheapest_period_day_count * f.price_per_day
                + ild.rental_cheapest_period_week_count * f.price_per_week
                + ild.rental_cheapest_period_four_week_count * f.price_per_month
            when billing_type = 'monthly' then iff(cycle_bill_days > 28,(f.price_per_month / 28) * cycle_bill_days,
                  ild.rental_cheapest_period_hour_count * f.price_per_hour
                + ild.rental_cheapest_period_day_count * f.price_per_day
                + ild.rental_cheapest_period_week_count * f.price_per_week
                + ild.rental_cheapest_period_month_count * f.price_per_month)
        end as floor_rate,
        case
            when book_rate is not null and book_rate != 0
                then (1 - (actual_rate / book_rate))::numeric(20, 2)
        end as percent_discount,
        case
            when actual_rate < floor_rate then 3
            when actual_rate >= floor_rate and actual_rate < book_rate then 2
            when actual_rate >= book_rate then 1
            else 2
        end as rate_tier,
        coalesce(actual_rate < floor_rate, false) as is_below_floor,
        coalesce(
            actual_rate >= floor_rate
            and actual_rate < benchmark_rate, false
        ) as is_btwn_floor_bench,
        coalesce(actual_rate >= benchmark_rate, false) as is_above_bench,
        case when is_above_bench then amount else 0 end as above_bench_collected_revenue,
        case when is_btwn_floor_bench then amount else 0 end as btwn_floor_bench_collected_revenue
    from {{ ref("int_admin_invoice_line_detail") }} as ild
    left join {{ ref("stg_es_warehouse_public__assets_aggregate") }} as aa
        on ild.asset_id = aa.asset_id
    left join {{ ref("stg_es_warehouse_public__rentals") }} as r
        on ild.rental_id = r.rental_id
    left join {{ ref("stg_es_warehouse_public__users") }} as u
        on ild.primary_salesperson_id = u.user_id
    -- book rate, previously called online rate
    left join {{ ref("stg_branch_rental_rates_corrections") }} as o
        on o.rate_type_id = 1 -- Book
            and r.equipment_class_id = o.equipment_class_id
            and ild.market_id = o.branch_id
            and ild.billing_approved_date between o.start_date and coalesce(
                o.end_date, '2099-12-31 23:59:59.999'::timestamp_ntz
            )
    left join {{ ref("stg_branch_rental_rates_corrections") }} as b -- benchmark rate
        on b.rate_type_id = 2 -- Benchmark
            and r.equipment_class_id = b.equipment_class_id
            and ild.market_id = b.branch_id
            and ild.billing_approved_date between b.start_date and coalesce(
                b.end_date, '2099-12-31 23:59:59.999'::timestamp_ntz
            )
    left join {{ ref("stg_branch_rental_rates_corrections") }} as f -- floor rate
        on f.rate_type_id = 3 -- Floor
            and r.equipment_class_id = f.equipment_class_id
            and ild.market_id = f.branch_id
            and ild.billing_approved_date between f.start_date and coalesce(
                f.end_date, '2099-12-31 23:59:59.999'::timestamp_ntz
            )
    inner join {{ ref("market") }} as m
        on ild.market_id = m.child_market_id
    where ild.line_item_type_id in (6, 8, 108, 109) -- Commissions Line Items
        and not ild.is_intercompany
        and ild.billing_approved_date is not null
        -- Payment collected within 120 days - i.e. collected revenue
        and datediff('hour', ild.billing_approved_date, ild.paid_date) / 24 < 120
)

select *
from out
